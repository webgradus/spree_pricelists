require 'csv'
class Spree::Importers::BaseImporter

  attr_reader :pricelist, :file_path, :starting_row, :log, :taxonomy, :taxon

  def self.parse(pricelist_id, file, starting_row)
    tmp_file_path = create_tmp_csv_file(file)
    delayed_start(pricelist_id, tmp_file_path, starting_row)
  end

  def initialize(pricelist, file_path, begin_point)
    @log = Logger.new(STDOUT)
    @pricelist = pricelist
    @starting_row = begin_point
    @file_path = file_path
    @taxon = Spree::Taxon.find_or_create_by(:name => @pricelist.name)
    @taxonomy = @taxon.taxonomy
    @parsed_products = []
    @taxon_root = Spree::Taxon.where(:name => @pricelist.name).first
    
  end

  def import
    log.info("#"*25 << "Start #{Time.now.to_s}" << "#"*25)
    current_row = 1
    CSV.foreach(file_path, col_sep: ';') do |row|
      parse_csv_row(row) if current_row >= starting_row.to_i
      current_row += 1
    end
    update_missed_products
    clear_tmp_files
  end

  protected

  def self.find_all_by_name(name)
    find(:all, :conditions => ["LOWER(name) = ?", name.downcase])
  end

  def update_missed_products
    # we need to delay it cause we need to make sure all DataFactory workers were done
    Spree::UpdateMissedProductsWorker.perform_in(10.minutes, pricelist.id, @parsed_products)
  end

  def clear_tmp_files
    Dir["tmp/*.xlsx"].each { |f| File.delete(f) }
    Dir["tmp/*.csv"].each { |f| File.delete(f) }
  end

  def parse_csv_row(row)
    # we consider index starting from 1
    sku = pricelist.sku_column.present? ? row[pricelist.sku_column.to_i - 1] : nil
    desc = pricelist.desc_column.present? ? row[pricelist.desc_column.to_i - 1] : nil
    price = prepare_price(row[pricelist.cost_price_column.to_i - 1])
    attrs = { sku: sku,
              description: desc,
              name: row[pricelist.name_column.to_i - 1],
              price: price,
              cost_price: row[pricelist.cost_price_column.to_i - 1].to_f,
              quantity: pricelist.quantity_column.present? ? row[pricelist.quantity_column.to_i - 1].to_i : nil,
              available_on: Time.now
    }
    product_properties = {
      property1_label: pricelist.property1_label.present? ? pricelist.property1_label : nil ,
      property2_label: pricelist.property2_label.present? ? pricelist.property2_label : nil ,
      property3_label: pricelist.property3_label.present? ? pricelist.property3_label : nil ,
      property4_label: pricelist.property4_label.present? ? pricelist.property4_label : nil ,
      property5_label: pricelist.property5_label.present? ? pricelist.property5_label : nil ,
      property6_label: pricelist.property6_label.present? ? pricelist.property6_label : nil ,
      property1: pricelist.property1.present? ? row[pricelist.property1.to_i - 1] : nil ,
      property2: pricelist.property2.present? ? row[pricelist.property2.to_i - 1] : nil ,
      property3: pricelist.property3.present? ? row[pricelist.property3.to_i - 1] : nil ,
      property4: pricelist.property4.present? ? row[pricelist.property4.to_i - 1] : nil ,
      property5: pricelist.property5.present? ? row[pricelist.property5.to_i - 1] : nil ,
      property6: pricelist.property6.present? ? row[pricelist.property6.to_i - 1] : nil 
    }

    variant = pricelist.parent_column.present? ? row[pricelist.parent_column.to_i - 1] : nil
    
    options = {
      variant: variant,
      otype1_label: pricelist.otype1_label.present? ? pricelist.otype1_label : nil ,
      otype2_label: pricelist.otype2_label.present? ? pricelist.otype2_label : nil,
      otype3_label: pricelist.otype3_label.present? ? pricelist.otype3_label : nil,
      otype4_label: pricelist.otype4_label.present? ? pricelist.otype4_label : nil,
      otype1: pricelist.otype1.present? ? row[pricelist.otype1.to_i - 1] : nil,
      otype2: pricelist.otype2.present? ? row[pricelist.otype2.to_i - 1] : nil,
      otype3: pricelist.otype3.present? ? row[pricelist.otype3.to_i - 1] : nil,
      otype4: pricelist.otype4.present? ? row[pricelist.otype4.to_i - 1] : nil

    }

    if row_is_taxon?(row)
      create_taxon(row)
      @up = false
    else
      if valid?(attrs)
        # we need this cause we want to check products that gone from price
        @parsed_products << attrs[:name]
        Spree::DataFactoryWorker.perform_async(pricelist.id, taxonomy.id, taxon.id, attrs, product_properties, options)
      end
      @up = true
    end
  end

  def valid?(attrs)
    # OVERRIDE THIS IN SUBCLASSES IF NECESSARY
    attrs[:name].present? && attrs[:price].present?
  end

  def prepare_price(price_value)
    # OVERRIDE THIS IN SUBCLASSES IF NECESSARY
    price_value.to_f * (pricelist.margin || 1)
  end

  def row_is_taxon?(row)
    return row.compact.count == 1
  end

  def create_taxon(row)
    # if @up
    #   parent = taxon.parent
    #   parent = parent || @taxon_root
    # else
    #   parent = taxon
    #   if taxon.products.count(:id) == 0 && taxon.parent_id != taxonomy.root.id && !taxon.parent_id.nil?
    #     log.info("Переназначаем родителя #{taxon.name}")
    #     taxon.parent = taxonomy.root
    #     taxon.permalink=''
    #     taxon.set_permalink
    #     taxon.save
    #   end
    # end
    @taxon = save_taxon(@taxon_root, row)
  end

  def save_taxon(parent, row)
    log.info("Переназначаем родителя #{taxon.name}")
    # tax = Spree::Taxon.where("name ILIKE ?", row.compact.first.to_s).map{|x| x if x.parent_id == parent.id or (x.parent.parent_id == parent.id if x.parent)}.compact.first
    tax = Spree::Taxon.where(:name => row.compact.first.to_s).map{|x| x if x.parent_id == parent.id or (x.parent.parent_id == parent.id if x.parent) or (x.parent.parent.parent_id == parent.id if x.parent.parent)}.compact.first
    if tax.nil?
      tax = Spree::Taxon.new(:name=>row.compact.first.mb_chars.capitalize.to_s)
      
      tax.taxonomy = taxonomy
      tax.parent=parent
      tax.save
    end
    return tax
  end

  def self.delayed_start(parser_id, file_path,begin_point)
    Spree::ImportPricelistWorker.perform_async(parser_id, file_path, begin_point)
  end

  def self.create_tmp_csv_file(file)
    csv_tmp_file = "#{Rails.root}/tmp/#{Time.now.strftime("%Y%m%d%H%M%S")}.csv"
    tmp_file = "#{Rails.root}/tmp/#{Time.now.strftime("%Y%m%d%H%M%S")}.xlsx"
    File.open(tmp_file, 'wb') do |f|
      f.write file.read
    end
    unless system("python lib/xlsx2csv.py -i -d '\;' #{tmp_file} #{csv_tmp_file}")
      raise "Invalid XLSX format ERROR!"
    end
    csv_tmp_file
  end

end
