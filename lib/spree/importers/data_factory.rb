class Spree::Importers::DataFactory
  LOGGER = Logger.new(STDOUT)

  def self.solve(taxonomy_id,taxon_id,attrs={})
    taxonomy = Spree::Taxonomy.find(taxonomy_id)
    taxon = Spree::Taxon.find(taxon_id)
    raise ArgumentError.new("Option :name is required") unless attrs['name']

    if attrs['name'][0] == "\""
      attrs['name'][0]=''
    end
    if attrs['name'][-1] == "\""
      attrs['name'][-1]=''
    end
    unless attrs['sku'].present?
      attrs['sku'] = "%06d" % rand(999999)
    end
    #replacer[0].each_with_index do |symb,index|
      #attrs['name'].gsub!(symb,replacer[1][index].to_s)
    #end
    attrs['price']=attrs['price'].to_f
    attrs['cost_price']=attrs['cost_price'].to_f
    product = Spree::Product.find_by_synonim(attrs['name'])
    if product.present?
      LOGGER.info("Товар #{attrs['name']} найден в таблице! Обновляем атрибуты: Cебестоимость: #{attrs['cost_price'].to_f.to_s} | Цена: #{attrs['price'].to_f.to_s} | Артикул: #{attrs['sku'].to_s}")
      #provider = product.first.provider_prices.where(" provider = '#{taxonomy.name}' ").first_or_create(:provider=>taxonomy.name)
      #provider.price = attrs['price'].to_f
      #provider.save
      product.first.update_attributes(attrs)
      product.first.taxons << taxon unless product.first.taxons.exists?(taxon)
    else
      conflict = Spree::Conflict.find_by_product_name(attrs['name'])
      similar_data_present = unless conflict
                               sim_prods = Spree::ProductSynonim.name_matching(attrs['name']).limit(1)
                               sim_prods.present? && sim_prods[0].pg_search_rank > Spree::Importers::MIN_PG_SEARCH_RANK ? true : false
                             end
      if similar_data_present || conflict.present?
        LOGGER.warn("Товар с похожим наименованием существует!(#{attrs['name']})")
        if conflict
          conflict.update_attributes(sku: attrs['sku'], cost_price: attrs['cost_price'], price: attrs['price'])
        else
          Spree::Conflict.create(product_name: attrs['name'], cost_price: attrs['cost_price'], price: attrs['price'], sku: attrs['sku'], provider_name: taxonomy.name)
        end
      else
        LOGGER.info("Создан новый товар! Наименование: #{attrs['name']} | Cебестоимость: #{attrs['cost_price'].to_f.to_s} | Цена: #{attrs['price'].to_f.to_s} | Артикул: #{attrs['sku'].to_s}")
        product=Spree::Product.create!(attrs.merge(shipping_category_id: Spree::ShippingCategory.first.id))
        #provider = product.provider_prices.where(" provider = '#{taxonomy.name}' ").first_or_create(:provider=>taxonomy.name)
        #provider.price = attrs['price'].to_f
        #provider.save
        product.taxons << taxon
      end
    end
    return true
  end
end
