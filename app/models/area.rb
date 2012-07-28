class Area < ActiveRecord::Base

  def get_areas_for_conversion(areas)
  # Takes array of Areas and returns an array e where e[0] is the 
  # name of the MSA and e[1] is an array of the state names associated with it
  # for only those Areas with multiple states
    areas_for_conversion = Array.new
    areas.each do |area|
      states = area[:name].match(/.+,\s(([A-Z]{2}-)*[A-Z]{2})/)
      if states != nil
        states = states.captures[0].split("-")
        areas_for_conversion[area[:name]] = states unless states.length < 2
      end
    end
    return areas_for_conversion
  end

end
