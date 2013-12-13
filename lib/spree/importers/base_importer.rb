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
    #@counter = @created = @updated = @issues = 0
    @file_path = file_path
    #@time_spend = Time.now
    #@rows_count = CSV.read(@file, quote_char: "\n").count
    #@up = false
    @taxonomy = Spree::Taxonomy.where(:name => @pricelist.name).first_or_create!
    @taxon = @taxonomy.root
  end

  def import
    log.info("#"*25 << "Start #{Time.now.to_s}" << "#"*25)
    current_row = 1
    CSV.foreach(file_path, col_sep: ';', quote_char: "\n") do |row|
      parse_csv_row(row) if current_row >= starting_row.to_i
      current_row += 1
    end
    clear_tmp_files
  end

  protected

  def clear_tmp_files
    Dir["tmp/*.xlsx"].each{ |f| File.delete(f)}
    Dir["tmp/*.csv"].each{ |f| File.delete(f)}
  end

  def parse_csv_row(row)
    # we consider index starting from 1
    sku = pricelist.sku_column.present? ? row[pricelist.sku_column.to_i - 1] : nil
    price = prepare_price(row[pricelist.cost_price_column.to_i - 1])
    attrs = { sku: sku,
              name: row[pricelist.name_column.to_i - 1],
              price: price,
              cost_price: row[pricelist.cost_price_column.to_i - 1].to_f,
              #available_on: ::Time.now
    }
    if row_is_taxon?(row)
      create_taxon(row)
      @up = false
    else
      if valid?(attrs)
        Spree::DataFactoryWorker.perform_async(taxonomy.id, taxon.id, attrs)
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
    if @up
      parent = taxon.parent
      parent = parent || taxonomy.root
    else
      parent = taxon
      if taxon.products.count(:id) == 0 && taxon.parent_id != taxonomy.root.id && !taxon.parent_id.nil?
        log.info("Переназначаем родителя #{taxon.name}")
        taxon.parent = taxonomy.root
        taxon.permalink=''
        taxon.set_permalink
        taxon.save
      end
    end
    @taxon = save_taxon(parent, row)
  end

  def save_taxon(parent, row)
    log.info("Переназначаем родителя #{taxon.name}")
    tax = Spree::Taxon.where(:name=>row.compact.first.to_s,:taxonomy_id => taxonomy.id,:parent_id=>parent.id).first
    if tax.nil?
      tax = Spree::Taxon.new(:name=>row.compact.first.to_s)
      tax.taxonomy = taxonomy
      tax.parent=parent
      tax.save
    end
    return tax
  end

  def self.delayed_start(parser_id, file_path,begin_point)
    Spree::ImportPricelistWorker.perform_async(parser_id, file_path,begin_point)
  end

  def self.create_tmp_csv_file(file)
    csv_tmp_file = "#{Rails.root}/tmp/#{Time.now.strftime("%Y%m%d%H%M%S")}.csv"
    tmp_file = "#{Rails.root}/tmp/#{Time.now.strftime("%Y%m%d%H%M%S")}.xlsx"
    File.open(tmp_file, 'wb') do |f|
      f.write  file.read
    end
    unless system("python lib/xlsx2csv.py -i -d '\;' #{tmp_file} #{csv_tmp_file}")
      #Spree::Parser::FAYE_MESSAGE.update_attributes body: "Не правильный формат файла XLSX!!!", message_type: "error"
      #Spree::Parser::FAYE_MESSAGE.reload
      #sync_update Spree::Parser::FAYE_MESSAGE
      raise "Invalid XLSX format ERROR!"
    end
    csv_tmp_file
  end

end
