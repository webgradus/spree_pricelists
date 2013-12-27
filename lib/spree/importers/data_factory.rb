class Spree::Importers::DataFactory

    attr_reader :log, :taxonomy, :taxon, :attrs

    def initialize(taxonomy_id, taxon_id, attrs={})
        @log = Logger.new(STDOUT)
        @taxonomy = Spree::Taxonomy.find(taxonomy_id)
        @taxon = Spree::Taxon.find(taxon_id)
        @attrs = attrs
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
        product.update_attributes(attrs.except('sku', 'quantity', 'name'))
        product.taxons << taxon unless product.taxons.exists?(taxon)
        update_quantity(product)
    end

    def create_product
        log.info("Создан новый товар! Наименование: #{attrs['name']} | Cебестоимость: #{attrs['cost_price'].to_f.to_s} | Цена: #{attrs['price'].to_f.to_s} | Артикул: #{attrs['sku'].to_s}")
        product = Spree::Product.create!(attrs.merge(shipping_category_id: Spree::ShippingCategory.first.id).except('quantity'))
        product.taxons << taxon
        update_quantity(product)
    end

    def update_quantity(product)
        stock_location = Spree::StockLocation.active.first
        if stock_location
          # if pricelist has quantity column, we update quantity
          # stock location should be backorderable: false by default
          # otherwise: we set products as backorderable
          if attrs['quantity'].present?
            stock_movement = stock_location.stock_movements.build(quantity: attrs['quantity'])
            stock_movement.stock_item = stock_location.set_up_stock_item(product.master)
            stock_movement.save!
          else
            stock_item = stock_location.stock_item_or_create(product.master)
            stock_item.update_attributes(backorderable: true)
          end
        end
    end

    def handle_missing_product
        conflict = Spree::Conflict.find_by_product_name(attrs['name'])
        similar_data_present = unless conflict
                                   sim_prods = Spree::ProductSynonim.name_matching(attrs['name']).limit(1)
                                   sim_prods.present? && sim_prods[0].pg_search_rank > Spree::Importers::MIN_PG_SEARCH_RANK ? true : false
                               end
        if similar_data_present || conflict.present?
            handle_conflict(conflict)
        else
            create_product
        end
    end

    def handle_conflict(conflict)
        log.warn("Товар с похожим наименованием существует!(#{attrs['name']})")
        if conflict
            conflict.update_attributes(sku: attrs['sku'], cost_price: attrs['cost_price'], price: attrs['price'])
        else
            Spree::Conflict.create(product_name: attrs['name'], cost_price: attrs['cost_price'], price: attrs['price'], sku: attrs['sku'], provider_name: taxonomy.name)
        end
    end
end
