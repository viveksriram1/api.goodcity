# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

donor_conditions = YAML.load_file("#{Rails.root}/db/donor_conditions.yml")
donor_conditions.each do |name, value|
  FactoryGirl.create(:donor_condition,
    name_en: name,
    name_zh_tw: value[:name_zh_tw] )
end

rejection_reasons = YAML.load_file("#{Rails.root}/db/rejection_reasons.yml")
rejection_reasons.each do |name_en, value|
  FactoryGirl.create(:rejection_reason,
    name_en: name_en,
    name_zh_tw: value[:name_zh_tw] )
end

cancellation_reasons = YAML.load_file("#{Rails.root}/db/cancellation_reasons.yml")
cancellation_reasons.each do |name_en, value|
  FactoryGirl.create(:cancellation_reason,
    name_en: name_en,
    name_zh_tw: value[:name_zh_tw],
    visible_to_admin: value[:visible_to_admin] )
end

districts = YAML.load_file("#{Rails.root}/db/districts.yml")
districts.each do |name_en, value|
  # FactoryGirl creates the correct territory for us
  FactoryGirl.create :district, name_en: name_en, latitude: value[:latitude], longitude: value[:longitude]
end

timeslots = [["10:30am-1pm", "上午10:30時至下午1時"], ["2PM-4PM", "下午2時至下午4時"]]
timeslots.each do |name|
  FactoryGirl.create :timeslot, name_en: name.first, name_zh_tw: name.last
end

gogovan_transports = YAML.load_file("#{Rails.root}/db/gogovan_transports.yml")
gogovan_transports.each do |name, value|
  FactoryGirl.create :gogovan_transport, name_en: name, name_zh_tw: value[:name_zh_tw], disabled: value[:disabled]
end

crossroads_transports = YAML.load_file("#{Rails.root}/db/crossroads_transports.yml")
crossroads_transports.each do |name, value|
  FactoryGirl.create :crossroads_transport, name_en: name, name_zh_tw: value[:name_zh_tw], cost: value[:cost], truck_size: value[:truck_size]
end

CrossroadsTransport.find_by(name_en: "Disable").update_column(:is_van_allowed, false)

holidays = YAML.load_file("#{Rails.root}/db/holidays.yml")
holidays.each do |key, value|
  date_value = DateTime.parse(value[:holiday]).in_time_zone(Time.zone)
  holiday = Holiday.where(
    name: value[:name],
    year: value[:year],
    holiday: date_value
  ).first_or_create
end

organisation_types = YAML.load_file("#{Rails.root}/db/organisation_types.yml")
organisation_types.each do |key, value|
  OrganisationType.create(
    name_en: value[:name_en],
    name_zh_tw: value[:name_zh_tw],
    category_en: value[:category_en],
    category_zh_tw: value[:category_zh_tw] )
end

package_types = YAML.load_file("#{Rails.root}/db/package_types.yml")
package_types.each do |code, value|
  PackageType.create(
    code: code,
    name_en: value[:name_en],
    name_zh_tw: value[:name_zh_tw],
    other_terms_en: value[:other_terms_en],
    other_terms_zh_tw: value[:other_terms_zh_tw] )
end

package_types.each do |code, value|
  parent_package = PackageType.find_by(code: code)

  if(value[:default_packages])
    default_packages = value[:default_packages].gsub(" ", "").split(",")
    default_packages.each do |default_package|
      child_package = PackageType.find_by(code: default_package)
      SubpackageType.create(
        package_type: parent_package,
        child_package_type: child_package,
        is_default: true)
    end
  end

  if(value[:other_packages])
    other_packages = value[:other_packages].gsub(" ", "").split(",")
    other_packages.each do |other_package|
      child_package = PackageType.find_by(code: other_package)
      SubpackageType.create(
        package_type: parent_package,
        child_package_type: child_package)
    end
  end
end

purposes = YAML.load_file("#{Rails.root}/db/purposes.yml")
purposes.each do |key, value|
  holiday = Purpose.where(
    name_en: value[:name_en],
    name_zh_tw: value[:name_zh_tw],
  ).first_or_create
end

# Create System User
FactoryGirl.create(:user, :system)

# Create api-write permission
FactoryGirl.create(:permission, name: "api-write")

# Create PackageCategories
PackageCategoryImporter.import

# Create PackageCategoriesPackageType
PackageCategoryImporter.import_package_relation

# Don't run the following setup on the live server.
# This is for dummy data
unless ENV['LIVE'] == "true"

  donor_attributes = [
    { mobile: "+85251111111", first_name: "David", last_name: "Dara51" },
    { mobile: "+85251111112", first_name: "Daniel", last_name: "Dell52" },
    { mobile: "+85251111113", first_name: "Dakota", last_name: "Deryn53" },
    { mobile: "+85251111114", first_name: "Delia", last_name: "Devon54" },
  ]
  donor_attributes.each {|attr| FactoryGirl.create(:user, attr) }

  reviewer_attributes = [
    { mobile: "+85261111111", first_name: "Rachel", last_name: "Riley61" },
    { mobile: "+85261111112", first_name: "Robyn", last_name: "Raina62" },
    { mobile: "+85261111113", first_name: "Rafael", last_name: "Ras63" },
    { mobile: "+85261111114", first_name: "Raj", last_name: "Rakim64" },
  ]
  reviewer_attributes.each {|attr| FactoryGirl.create(:user, :reviewer, attr) }

  supervisor_attributes = [
    { mobile: "+85291111111", first_name: "Sarah", last_name: "Sahn91" },
    { mobile: "+85291111112", first_name: "Sally", last_name: "Salwa92" },
    { mobile: "+85291111113", first_name: "Saad", last_name: "Safa93" },
    { mobile: "+85291111114", first_name: "Scott", last_name: "Sandro94" },
  ]
  supervisor_attributes.each {|attr| FactoryGirl.create(:user, :supervisor, attr) }
end
