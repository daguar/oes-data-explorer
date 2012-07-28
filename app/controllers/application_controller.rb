require 'json'
require 'DOLDataSDK'

class ApplicationController < ActionController::Base
  
  protect_from_forgery
  rescue_from NoMethodError, :with => :no_method_save

  # Turning off caching, because using flashes now
  #caches_page :index

  def index
    @states = Area.find_all_by_typecode('S').sort_by { |s| s.name }
  end

  def getmsas
    @msas = Area.find_all_by_state_code_and_typecode(Area.find_by_name(params[:name]).state_code, 'M').sort_by { |a| a['code'] }
    render :partial => "msas", :locals => { :msas => @msas }
  end

  def getdata
    # maybe move context to class since it doesn't change?
    puts Settings.dol_key, Settings.dol_secret
    context = DOL::DataContext.new 'http://api.dol.gov', Settings.dol_key, Settings.dol_secret
    request1 = DOL::DataRequest.new context
    # Conditional for different area cases
    # If national selected
    if params[:area][:state] == ""
      @area_name = "National"
      @area_code = "0000000"
    # If only a state was selected
    elsif params[:area][:msa] == ""
      @area_name = params[:area][:state]
      @area_code = Area.find_by_name(@area_name).code.to_s
    # Else, i.e., if both state and MSA were selected
    else
      @area_name = Area.find_by_code(params[:area][:msa]).name
      @area_code = params[:area][:msa].to_s #Area.find_by_name(@area_name).code.to_s
    end
    @job_title = params[:jobs][:job_title]
    @job_code = Job.find_by_title(@job_title).code.to_s
    @job_category = Job.find_by_title(@job_title).category.to_s
    @datatype_codes = { :_10th => '11', :_25th => '12', :median => '13', :_75th => '14', :_90th => '15' }
    @series_ids = Hash.new
    @series_ids['0000000'] = Hash.new
    @series_ids[@area_code] = Hash.new

    @series_ids.each_key do | areakey |
      @datatype_codes.each do | variablekey, value |
        request1.call_api('STATISTICS/OES/OE_SERIES', :select => "SERIES_ID", :filter => "(DATATYPE_CODE eq '#{value}') and (OCCUPATION_CODE eq '#{@job_code}') and (AREA_CODE eq '#{areakey}') and (INDUSTRY_CODE eq '000000') and (BEGIN_YEAR eq '2011') and (BEGIN_PERIOD eq 'S01') and (END_YEAR eq '2011') and (END_PERIOD eq 'S01')") do |results, error|
          if error
            puts error
            @series_ids[areakey][variablekey] = 'N/A'
          elsif results.length != 1
            puts "Oops. DOL gave did not give us 1 series_id result. It gave us #{results.length}."
            puts "Results were: ", results.to_s
            @series_ids[areakey][variablekey] = 'N/A'
          else
            @series_ids[areakey][variablekey] = results[0]['SERIES_ID']
          end
        end
      end
    end
    request1.wait_until_finished
    puts "@series_ids == #{@series_ids}"

    # Set up value store for returned values
    @values = Hash.new
    @values['0000000'] = Hash.new
    @values[@area_code] = Hash.new
    # May want to set default values as done above
    request2 = DOL::DataRequest.new context
    @series_ids.each_key do | areakey |
      @series_ids[areakey].each do | variablekey, value |
        request2.call_api 'STATISTICS/OES/OE_DATA_PUB', :select => 'VALUE', :filter => "SERIES_ID eq '#{value}'" do |results, error|
          if error
            puts error
            @values[areakey][variablekey] = 'N/A'
          elsif results.length != 1
            puts "Oops. DOL gave did not give us 1 value result. It gave us #{results.length}."
            @values[areakey][variablekey] = 'N/A'
          else
            @values[areakey][variablekey] = results[0]['VALUE']
          end
        end
      end
    end
    request2.wait_until_finished
    puts "@values == #{@values}"
    if @values[@area_code][:median] == "N/A"
      if @values['0000000'][:median] == "N/A"
        flash[:notice] = "Sorry! I couldn't find data for that job in the OES. (If it's any consolation, I'm off to robot time-out.)"
        redirect_to :root
      else
        flash[:notice] = "Sorry! Data wasn't available for " + @area_name + ". But here's the national data."
        @area_name = "National"
      end
    end
  end

  private
  def no_method_save
    flash[:notice] = 'Oops! Something went wrong. Try letting the Job Title auto-complete, and then clicking on the job you want.'
    redirect_to :root
  end

end

