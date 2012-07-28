# This is a script to download all the necessary data through the DOL API that is imported by the loaddata rake task. 
# Because the source comes with the CSV files, this has not been cleaned up just yet, and so contains extraneous data 
# pulls, and may have other issues. It is provided here simply to help someone trying to do a related task 
# (e.g., retrieve data for a different year, other DOL data through the API, etc.)

# TL;DR - It's wicked ugly and needs to be refactored, but low-prior since the CSV's are already packaged.

require 'csv'
require 'json'
require './lib/DOLDataSDK'


namespace :doldownload do

  task :makecsvs => :environment do

    # First, get the mappings of occupation_code and occupation_name for the general SOC job titles
    request = DOL::DataRequest.new(DOL::DataContext.new('http://api.dol.gov', Settings.dol_key, Settings.dol_secret))
    store = Array.new
    store[0] = {:occupation_code => 'occupation_code', :occupation_name => 'occupation_name'}
    currentlength = 100
    numbertoskip = 0
    n = 1
    while(currentlength > 0)
      request.call_api 'STATISTICS/OES/OE_OCCUPATION', :select => "OCCUPATION_CODE,OCCUPATION_NAME", :orderby => "OCCUPATION_CODE", :skip => numbertoskip do |results, error|
        if error
          puts error
        else
          results.each do |result|
            store[n] = {:occupation_code => result['OCCUPATION_CODE'], :occupation_name => result['OCCUPATION_NAME']}
            #puts "store[n].to_s is #{store[n].to_s}"
            n = n + 1
          end
          puts "Results' length is #{results.length}"
          currentlength = results.length
          puts "Results' class is #{results.class}"
        end
      end
      request.wait_until_finished
      numbertoskip = numbertoskip + 100
      puts "numbertoskip is #{numbertoskip}"
      sleep(2)
    end
    #puts store

    # Delete header row
    store.delete_at(0)
    # Write to file
    CSV.open("./jobcats.csv", "w") do |csv|
      store.each do |row|
        csv << [row[:occupation_code], row[:occupation_name]]
      end
    end
    puts "jobcats.csv made!"




    # Second, get the areas
    request = DOL::DataRequest.new(DOL::DataContext.new('http://api.dol.gov', Settings.dol_key, Settings.dol_secret))
    store = Array.new
    store[0] = {:area_code => 'area_code', :area_name => 'area_name', :areatype_code => 'areatype_code'}
    currentlength = 100
    numbertoskip = 0
    n = 1
    while(currentlength > 0)
      request.call_api 'STATISTICS/OES/OE_AREA', :select => "AREA_CODE,AREA_NAME,AREATYPE_CODE", :orderby => "AREA_CODE", :skip => numbertoskip do |results, error|
        if error
          puts error
        else
          results.each do |result|
            store[n] = {:area_code => result['AREA_CODE'], :area_name => result['AREA_NAME'], :areatype_code => result['AREATYPE_CODE']}
            #puts "store[n].to_s is #{store[n].to_s}"
            n = n + 1
          end
          puts "Results' length is #{results.length}"
          currentlength = results.length
          puts "Results' class is #{results.class}"
        end
      end
      request.wait_until_finished
      numbertoskip = numbertoskip + 100
      puts "numbertoskip is #{numbertoskip}"
      sleep(2)
    end

    puts store

    # Delete header row
    store.delete_at(0)

    # Write to file
    CSV.open("./areas.csv", "w") do |csv|
      store.each do |row|
        csv << [row[:area_code], row[:area_name], row[:areatype_code]]
      end
    end
    puts "areas.csv made!"





    # Third, get industry codes
    request = DOL::DataRequest.new(DOL::DataContext.new('http://api.dol.gov', Settings.dol_key, Settings.dol_secret))
    store = Array.new
    store[0] = {:industry_code => 'industry_code', :industry_name => 'industry_name'}
    currentlength = 100
    numbertoskip = 0
    n = 1
    while(currentlength > 0)
      request.call_api 'STATISTICS/OES/OE_INDUSTRY', :select => "INDUSTRY_CODE,INDUSTRY_NAME", :orderby => "INDUSTRY_CODE", :skip => numbertoskip do |results, error|
        if error
          puts error
        else
          results.each do |result|
            store[n] = {:industry_code => result['INDUSTRY_CODE'], :industry_name => result['INDUSTRY_NAME']}
            #puts "store[n].to_s is #{store[n].to_s}"
            n = n + 1
          end
          puts "Results' length is #{results.length}"
          currentlength = results.length
          puts "Results' class is #{results.class}"
        end
      end
      request.wait_until_finished
      numbertoskip = numbertoskip + 100
      puts "numbertoskip is #{numbertoskip}"
      sleep(2)
    end

    puts store

    # Delete header row
    store.delete_at(0)

    # Write to file
    CSV.open("./industries.csv", "w") do |csv|
      store.each do |row|
        csv << [row[:industry_code], row[:industry_name]]
      end
    end
    puts "industries.csv made!"









    # Fourth, get footnote codes
    request = DOL::DataRequest.new(DOL::DataContext.new('http://api.dol.gov', Settings.dol_key, Settings.dol_secret))
    store = Array.new
    store[0] = {:footnote_code => 'footnote_code', :footnote_name => 'footnote_text'}
    currentlength = 100
    numbertoskip = 0
    n = 1
    while(currentlength > 0)
      request.call_api 'STATISTICS/OES/OE_FOOTNOTE', :select => "FOOTNOTE_CODE,FOOTNOTE_TEXT", :orderby => "FOOTNOTE_CODE", :skip => numbertoskip do |results, error|
        if error
          puts error
        else
          results.each do |result|
            store[n] = {:footnote_code => result['FOOTNOTE_CODE'], :footnote_text => result['FOOTNOTE_TEXT']}
            #puts "store[n].to_s is #{store[n].to_s}"
            n = n + 1
          end
          puts "Results' length is #{results.length}"
          currentlength = results.length
          puts "Results' class is #{results.class}"
        end
      end
      request.wait_until_finished
      numbertoskip = numbertoskip + 100
      puts "numbertoskip is #{numbertoskip}"
      sleep(2)
    end

    puts store

    # Delete header row
    store.delete_at(0)

    # Write to file
    CSV.open("./footnotecodes.csv", "w") do |csv|
      store.each do |row|
        csv << [row[:footnote_code], row[:footnote_text]]
      end
    end
    puts "footnotecodes.csv made!"









    # Fifth, get MSA to state map
    request = DOL::DataRequest.new(DOL::DataContext.new('http://api.dol.gov', Settings.dol_key, Settings.dol_secret))
    store = Array.new
    store[0] = {:msa_code => 'msa_code', :state_code => 'state_code'}
    currentlength = 100
    numbertoskip = 0
    n = 1
    while(currentlength > 0)
      request.call_api 'STATISTICS/OES/OE_STATEMSA', :select => "MSA_CODE,STATE_CODE", :orderby => "MSA_CODE", :skip => numbertoskip do |results, error|
        if error
          puts error
        else
          results.each do |result|
            store[n] = {:msa_code => result['MSA_CODE'], :state_code => result['STATE_CODE']}
            #puts "store[n].to_s is #{store[n].to_s}"
            n = n + 1
          end
          puts "Results' length is #{results.length}"
          currentlength = results.length
          puts "Results' class is #{results.class}"
        end
      end
      request.wait_until_finished
      numbertoskip = numbertoskip + 100
      puts "numbertoskip is #{numbertoskip}"
      sleep(2)
    end

    puts store

    # Delete header row
    store.delete_at(0)

    # Write to file
    CSV.open("./msas.csv", "w") do |csv|
      store.each do |row|
        csv << [row[:msa_code], row[:state_code]]
      end
    end
    puts "msas.csv made!"









    # Sixth, get these stupid state code names
    request = DOL::DataRequest.new(DOL::DataContext.new('http://api.dol.gov', Settings.dol_key, Settings.dol_secret))
    store = Array.new
    store[0] = {:state_code => 'state_code', :state_name => 'state_name'}
    currentlength = 100
    numbertoskip = 0
    n = 1
    while(currentlength > 0)
      request.call_api 'Geography/State', :select => "StateCode,StateName", :orderby => "StateCode", :skip => numbertoskip do |results, error|
        if error
          puts error
        else
          results.each do |result|
            store[n] = {:state_code => result['StateCode'], :state_name => result['StateName']}
            #puts "store[n].to_s is #{store[n].to_s}"
            n = n + 1
          end
          puts "Results' length is #{results.length}"
          currentlength = results.length
          puts "Results' class is #{results.class}"
        end
      end
      request.wait_until_finished
      numbertoskip = numbertoskip + 100
      puts "numbertoskip is #{numbertoskip}"
      sleep(2)
    end

    puts store

    # Delete header row
    store.delete_at(0)

    # Write to file
    CSV.open("./statecodes.csv", "w") do |csv|
      store.each do |row|
        csv << [row[:state_code], row[:state_name]]
      end
    end
    puts "statecodes.csv made!"

  end

end

