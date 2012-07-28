require 'csv'

namespace :loaddata do
  
  # Loads the more specific "SOC direct match" job titles
  task :direct_match_jobs => :environment do
    # Old load
    #CSV.foreach('./datadumps/CONVERTED_soc_2010_direct_match_title_file.csv', :quote_char => '"', :col_sep =>',', :row_sep =>:auto, :encoding => 'windows-1251:utf-8') { |row| Job.create!(:occupation_code => row[0].gsub("-","").to_s, :job_category => row[1], :job_title => row[2]) } #, :illustrative_example => row[3] } ----------- could do this if necessary
    # Have to manually exclude header here; for below, removed headers at the point of download (this inconsistency is perhaps suboptimal, but no time for love Dr. Jones)
    c = CSV.open('./datadumps/CONVERTED_soc_2010_direct_match_title_file.csv', :quote_char => '"', :col_sep =>',', :row_sep =>:auto, :encoding => 'windows-1251:utf-8')
    c.drop(1).each { |row| Job.create!(:code => row[0].gsub("-","").to_s, :category => row[1], :title => row[2]) } 
  end

  # Loads the less specific SOC categories, essentially including "job_category" as a chooseable option
  # Sets the more specific "job_title" (used for user input) to the same as "job_category" (since the source here is the list of all job_category's) 
  task :job_categories => :environment do
    CSV.foreach('./datadumps/jobcats.csv', :quote_char => '"', :col_sep =>',', :row_sep =>:auto) { |row| Job.create!(:code => row[0].to_s, :category => row[1], :title => row[1]) }
  end

  # Loads the human-readable version of area codes, so that user can select MSA/state/national, and backend can translate that to a DOL area_code for the API call
  task :areas => :environment do
    CSV.foreach('./datadumps/areas.csv', :quote_char => '"', :col_sep =>',', :row_sep =>:auto) { |row| Area.create!(:code => row[0].to_s, :name => row[1], :typecode => row[2].to_s) }
  end

  task :state_codes => :environment do
  #put in :all rake task
    msahash = Hash.new
    CSV.foreach('./datadumps/msas.csv', :quote_char => '"', :col_sep =>',', :row_sep =>:auto) { |row| msahash[row[0]] = row[1] }
    Area.all.each { |a| a.update_attributes!(:state_code => msahash[a.code]) }
    msahash = 0
    statehash = Hash.new
    CSV.foreach('./datadumps/statecodes.csv', :quote_char => '"', :col_sep =>',', :row_sep =>:auto) do |row|
      if row[0].length == 1
        statehash[row[1]] = row[0].to_s.prepend("0")
      else
        statehash[row[1]] = row[0]
      end
    end
    Area.find_all_by_state_code(nil).each { |a| a.update_attributes!(:state_code => statehash[a.name]) }
  end

  task :multi_state_msas => :environment do
    all_areas = Area.all
    areas_for_conversion = Hash.new
    all_areas.each do |area|
      states = area[:name].match(/.+,\s(([A-Z]{2}-)*[A-Z]{2})/)
      if states != nil
        states = states.captures[0].split("-")
        areas_for_conversion[area[:name]] = states unless states.length < 2
      end
    end
    #areas_for_conversion = MSAConverter.get_areas_for_conversion(all_areas)
    areas_for_conversion.each do |area|
      a = Area.find_by_name(area[0])
      current_state_name = Area.find_by_state_code_and_typecode(a.state_code, 'S').name
      current_state_code = Carmen::state_code(current_state_name, 'US')
      area_state_codes = area[1]
      #puts "Area Name: #{area[0]}"
      #puts "Relevant State Codes: #{area[1]}"
      #puts "Current State: #{current_state_name}"
      states_to_add = Array.new
      area_state_codes.each { |asc| states_to_add << Carmen::state_name(asc, 'US') unless asc == current_state_code }
      #puts "States To Add: #{states_to_add}"
      states_to_add.each_with_index { |state, index| states_to_add[index] = "District of Columbia" if state == "District Of Columbia" }
      state_codes_to_add = Array.new
      states_to_add.each { |state_name| state_codes_to_add << Area.find_by_name(state_name).state_code }
      #puts "State Codes To Add: #{state_codes_to_add}"
      state_codes_to_add.each { |mystatecode| Area.create(:code => a.code, :name => a.name, :typecode => a.typecode, :state_code => mystatecode) }
    end

  end

  task :all => [:job_categories, :direct_match_jobs, :areas, :state_codes, :multi_state_msas ] do
    puts "All tasks run!"
  end

end
