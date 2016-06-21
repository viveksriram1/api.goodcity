namespace :goodcity do

  # After copying stockit live DB to stockit staging DB, run this rake task to
  # copy the values, in order to sync it with stockit items.
  # rake goodcity:update_existing_records_to_sync
  desc 'Load location details from stockit'
  task update_existing_records_to_sync: :environment do

    puts "Copy locations: START"
    locations_json = Stockit::LocationSync.index
    stockit_locations = JSON.parse(locations_json["locations"])

    if stockit_locations
      stockit_locations.each do |value|
        location = Location.where(
          building: value["building"],
          area: value["area"]
        ).first_or_create
        location.update_attribute(:stockit_id, value["id"])
      end
    end
    puts "Copy locations: END"

    puts "Copy codes: START"
    codes_json = Stockit::CodeSync.index
    stockit_codes = JSON.parse(codes_json["codes"])

    if stockit_codes

      stockit_codes.each do |value|
        is_new_code = false

        code = PackageType.where(code: value["code"]).first_or_initialize
        code.name_en = value["description_en"]
        code.name_zh_tw = value["description_zht"]
        code.stockit_id = value["id"]
        is_new_code = code.new_record?
        code.save

        if is_new_code && code.default_child_package_types.count.zero?
          SubpackageType.create(
            package_type: code,
            child_package_type: code,
            is_default: true)
        end
      end
    end
    puts "Copy codes: END"

    puts "Copy pallets and boxes: START"
    Package.update_all(box_id: nil)
    Package.update_all(pallet_id: nil)

    Rake::Task["goodcity:add_stockit_pallets_boxes"].execute
    puts "Copy pallets and boxes: END"

    puts "Copy stockit_organisations: START"
    Rake::Task["goodcity:add_stockit_organisations"].execute
    puts "Copy stockit_organisations: END"

    puts "Copy stockit_contacts: START"
    Rake::Task["goodcity:add_stockit_contacts"].execute
    puts "Copy stockit_contacts: END"

    puts "Copy stockit_local_orders: START"
    Rake::Task["goodcity:add_stockit_local_orders"].execute
    puts "Copy stockit_local_orders: END"

    puts "Copy stockit_designations: START"
    Rake::Task["goodcity:add_stockit_designations"].execute
    puts "Copy stockit_designations: END"

    puts "Copy stockit_items: START"
    Rake::Task["goodcity:add_stockit_items"].execute
    puts "Copy stockit_items: END"
  end
end