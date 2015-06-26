class Spree::Importers::DataFactory

    attr_reader :log, :taxonomy, :taxon, :attrs, :pricelist

    def initialize(pricelist_id, taxonomy_id, taxon_id, attrs={}, properties={})
        @log = Logger.new(STDOUT)
        @taxonomy = Spree::Taxonomy.find(taxonomy_id)
        @taxon = Spree::Taxon.find(taxon_id)
        @attrs = attrs
        @properties = properties
        @pricelist = Spree::Pricelist.find(pricelist_id)
        prepare_attrs
    end

    def solve
        raise ArgumentError.new("Option :name is required") unless attrs['name']
        products = Spree::Product.find_by_synonim(attrs['name'])
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
    end

    def update_product(product)
        log.info("Товар #{attrs['name']} найден в таблице! Обновляем атрибуты: Cебестоимость: #{attrs['cost_price'].to_f.to_s} | Цена: #{attrs['price'].to_f.to_s}")
        product.update(attrs.merge(pricelist_id: pricelist.id).except('sku', 'quantity', 'name', 'desc'))
        product.taxons << taxon unless product.taxons.exists?(taxon)
        product.update_stock_from_pricelist(attrs)
    end

    def create_product
        log.info("Создан новый товар! Наименование: #{attrs['name']} | Cебестоимость: #{attrs['cost_price'].to_f.to_s} | Цена: #{attrs['price'].to_f.to_s} | Артикул: #{attrs['sku'].to_s}")
        
        product = Spree::Product.create!(attrs.merge(pricelist_id: pricelist.id, shipping_category_id: Spree::ShippingCategory.first.id).except('quantity'))
        product.taxons << taxon
        product.update_stock_from_pricelist(attrs)
        # byebug
        Dir.chdir(Rails.root)
        Dir.chdir('.'+@pricelist.image_dir_column)
        if File.exists? attrs['sku'].to_s+'.JPEG'
            log.info("Создаем изображение к товару #{attrs['name']}")
            image_file = File.open(attrs['sku'].to_s+'.JPEG')
            image = product.images.create(:attachment => image_file, :alt => product.name.to_s)
            image_file.close
            
        end
        
        @properties.each do |k, v|
            # byebug
            unless @properties[k].nil?  
                case @properties[k]
                when @properties['prop1']
                    property = Spree::Property.where(name: "Бренд").first_or_create!(presentation: "Бренд")
                when @properties['prop2']
                    property = Spree::Property.where(name: "Тип кожи").first_or_create!(presentation: "Тип кожи")
                when @properties['prop3']
                    property = Spree::Property.where(name: "Тип волос").first_or_create!(presentation: "Тип волос")
                when @properties['prop4']
                    property = Spree::Property.where(name: "Оттенок").first_or_create!(presentation: "Оттенок")
                end
                product.product_properties.where(property_id: property.id).find_or_create_by(value: @properties[k]) 
            end
        end
    end

    def handle_missing_product
        conflict = Spree::Conflict.find_by_product_name(attrs['name'])
        similar_data_present = unless conflict
                                   sim_prods = Spree::ProductSynonim.name_matching(attrs['name']).with_pg_search_rank.limit(1)
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
        log.warn("Товар с похожим наименованием существует!(#{attrs['name']})")
        if conflict
            conflict.update_attributes(sku: attrs['sku'], cost_price: attrs['cost_price'], price: attrs['price'], pricelist_id: pricelist.id, quantity: attrs['quantity'])
        else
            Spree::Conflict.create(product_name: attrs['name'], cost_price: attrs['cost_price'], price: attrs['price'], sku: attrs['sku'], provider_name: taxonomy.name, pricelist_id: pricelist.id, quantity: attrs['quantity'])
        end
    end
end
