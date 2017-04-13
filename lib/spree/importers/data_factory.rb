class Spree::Importers::DataFactory

    attr_reader :log, :taxonomy, :taxon, :attrs, :pricelist

    def initialize(pricelist_id, taxonomy_id, taxon_id, attrs={}, product_properties={}, options={})
      @log = Logger.new(STDOUT)
      @taxonomy = Spree::Taxonomy.find(taxonomy_id)
      @taxon = Spree::Taxon.find(taxon_id)
      @attrs = attrs
      @product_properties = product_properties
      @options = options
      @pricelist = Spree::Pricelist.find(pricelist_id)
      prepare_attrs
    end

    def solve
      raise ArgumentError.new("Option :name is required") unless attrs['name']
      products = Spree::Product.find_by_synonim(attrs['name'].gsub(/\n/, ''))
      if products.present?
        update_product(products.first)
      else
        handle_missing_product
      end
    end

    protected

    def prepare_attrs
      if attrs['name'][0] == "\""
          @attrs['name'][0]=''
      end
      if attrs['name'][-1] == "\""
          @attrs['name'][-1]=''
      end
      unless attrs['sku'].present?
          @attrs['sku'] = "%06d" % rand(999999)
      end
      @attrs['price'] = attrs['price'].to_d
    end

    def update_product(product)
      log.info("Товар #{@attrs['name']} найден в таблице! Обновляем атрибуты: Cебестоимость: #{@attrs['cost_price'].to_f.to_s} | Цена: #{@attrs['price'].to_f.to_s}")
      product.update(@attrs.merge(pricelist_id: pricelist.id).except('sku', 'quantity', 'name', 'desc'))
      product.taxons << taxon unless product.taxons.exists?(taxon)
      product.update_stock_from_pricelist(@attrs)
    end

    def create_product
      log.info("Создан новый товар! Наименование: #{@attrs['name']} | Cебестоимость: #{@attrs['cost_price'].to_f.to_s} | Цена: #{@attrs['price'].to_f.to_s} | Артикул: #{@attrs['sku'].to_s}")

      if @options['variant'].present? && @options['variant'] != @attrs['sku']
        create_variants

      else

        product = Spree::Product.create!(@attrs.merge(pricelist_id: pricelist.id, shipping_category_id: Spree::ShippingCategory.first.id).except('quantity'))
        product.taxons << taxon
        product.update_stock_from_pricelist(@attrs)

        Dir.chdir(Rails.root)
        Dir.chdir('.' + @pricelist.image_dir_column)

        # check if image exist and attach it to variant
        if File.exists? @attrs['sku'].to_s + '.JPEG'
          log.info("Создаем изображение к товару #{@attrs['name']}")
          image_file = File.open(@attrs['sku'].to_s+".JPEG")
          image = product.images.create(:attachment => image_file, :alt => product.name.to_s)
          image_file.close

          i = 1
          while File.exists? @attrs['sku'].to_s + "_#{i}.JPEG" do
            image_file = File.open(@attrs['sku'].to_s + "_#{i}.JPEG")
            image = product.images.create(:attachment => image_file, :alt => product.name.to_s)
            image_file.close
            i += 1
          end
        end

        #create properties for product
        x = 1
        while @product_properties["property#{x}_label"].present? && @product_properties["property#{x}"].present? do
          property = Spree::Property.where(name: @product_properties["property#{x}_label"]).first_or_create!(presentation: @product_properties["property#{x}_label"])

          product.product_properties.where(property_id: property.id).find_or_create_by(value: @product_properties["property#{x}"])

          x += 1
        end

      end
    end

    def create_variants
      if Spree::Variant.find_by_sku(@options['variant']).nil?
        Spree::DataFactoryWorker.perform_in(10.minutes, @pricelist.id, @taxonomy.id, @taxon.id, @attrs, @properties, @options)
      else
        product = Spree::Product.find(Spree::Variant.find_by_sku(@options['variant']).product_id)

        variant = product.variants.where(sku: @attrs['sku']).first_or_create!(price: @attrs['price'])

        # if variant name is needed
        if Spree::Variant.column_names.include? "title"
          variant.update(:title => @attrs['name'])
        end

        # update stock
        variant.update_stock_from_pricelist(@attrs)

        log.info("Создан новый вариант к товару! Наименование: #{@attrs['name']} | Cебестоимость: #{@attrs['cost_price'].to_f.to_s} | Цена: #{@attrs['price'].to_f.to_s} | Артикул: #{@attrs['sku'].to_s}")

        # check if image exist and attach it to variant
        if File.exists? @attrs['sku'].to_s + '.JPEG'
          log.info("Создаем изображение к варианту #{@attrs['name']}")
          image_file = File.open(@attrs['sku'].to_s + '.JPEG')
          image = variant.images.create(:attachment => image_file, :alt => product.name.to_s)
          image_file.close
          i = 1
          while File.exists? @attrs['sku'].to_s + "_#{i}.JPEG" do
            image_file = File.open(@attrs['sku'].to_s + "_#{i}.JPEG")
            image = product.images.create(:attachment => image_file, :alt => product.name.to_s)
            image_file.close
            i += 1
          end


          y = 1
          while @options["otype#{y}_label"].present? && @options["otype#{y}"].present? do
            option_type = Spree::OptionType.where(name: @options["otype#{y}_label"]).first_or_create!(presentation: @options["otype#{y}_label"])
            product.product_option_types.where(option_type_id: option_type.id).first_or_create!
            variant.option_values << Spree::OptionValue.where(name: @options["otype#{y}"]).first_or_create!(name: @options["otype#{y}"], presentation: @options["otype#{y}"], option_type_id: option_type.id)
            y += 1
          end
        end
      end
    end

    def handle_missing_product
      conflict = Spree::Conflict.find_by_product_name(@attrs['name'])
      similar_data_present = unless conflict
                                 sim_prods = Spree::ProductSynonim.name_matching(@attrs['name']).with_pg_search_rank.limit(1)
                                 sim_prods.present? && sim_prods[0].pg_search_rank > Spree::Importers::MIN_PG_SEARCH_RANK ? true : false
                             end
      # if similar_data_present || conflict.present?
      #     handle_conflict(conflict)
      # else
      #     create_product
      # end
      create_product
    end

    def handle_conflict(conflict)
      log.warn("Товар с похожим наименованием существует!(#{@attrs['name']})")
      if conflict
        conflict.update_attributes(sku: @attrs['sku'], cost_price: @attrs['cost_price'], price: @attrs['price'], pricelist_id: pricelist.id, quantity: @attrs['quantity'])
      else
        Spree::Conflict.create(product_name: @attrs['name'], cost_price: @attrs['cost_price'], price: @attrs['price'], sku: @attrs['sku'], provider_name: taxonomy.name, pricelist_id: pricelist.id, quantity: @attrs['quantity'])
      end
    end
end
