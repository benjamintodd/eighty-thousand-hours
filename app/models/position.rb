# contains individual positions under experience in members profile
class Position < ActiveRecord::Base
  belongs_to :etkh_profile
  attr_accessible :position,
  				  :organisation,
  				  :start_date_month,
  				  :start_date_year,
  				  :end_date_month,
  				  :end_date_year

  def self.populate
    pos = Position.new(end_date_month: "July", end_date_year: 2011)
    pos.etkh_profile_id = 355
    pos.save
    pos = Position.new(end_date_month: "February", end_date_year: 2012)
    pos.etkh_profile_id = 355
    pos.save
    pos = Position.new(end_date_month: "January", end_date_year: 2012)
    pos.etkh_profile_id = 355
    pos.save
    pos = Position.new(end_date_month: "October", end_date_year: 2012)
    pos.etkh_profile_id = 355
    pos.save
    pos = Position.new(end_date_month: "February", end_date_year: 2011)
    pos.etkh_profile_id = 355
    pos.save
    pos = Position.new(end_date_year: 2012)
    pos.etkh_profile_id = 355
    pos.save
    pos = Position.new()
    pos.etkh_profile_id = 355
    pos.save
  end

  def self.custom_order(positions)
    # orders positions by year and then by month, with 

    # create array of positions ordered by year
    ordered = []
    positions.order("end_date_year DESC").each do |pos|
      ordered << pos
    end
    
    same_year_array = []

    # loop through all elements
    for i in 0..ordered.length-1
      p ordered[i]
      #debugger
      next if !ordered[i].end_date_year

      # assign starting point if not already done
      current_year = ordered[i].end_date_year if current_year.nil? 
      year_index = i if year_index.nil?

      # check if moved onto a new year
      if ordered[i].end_date_year != current_year
        if same_year_array
          # order array of same year elements
          same_year_array = same_year_array.sort {|a,b| a.order_month <=> b.order_month}

          # delete original entries of this year
          for j in year_index..i-1
            ordered.delete(ordered[year_index])
          end

          # insert into original array
          ordered.insert(year_index, *same_year_array)
        end

        # start of new year so store element index and add to array of same year elements
        current_year = ordered[i].end_date_year
        year_index = i
        same_year_array = []
      end
      
      # add element to array of same year elements
      same_year_array << ordered[i]
    end

    if same_year_array
      # order array of same year elements
      same_year_array = same_year_array.sort {|a,b| a.order_month <=> b.order_month}

      # delete original entries of this year
      for j in year_index..ordered.length-1
        ordered.delete(ordered[year_index])
      end

      # insert into original array
      ordered.insert(year_index, *same_year_array)
    end
    return ordered
  end

  def order_month
    return 0 if !self.end_date_month || self.end_date_month == ""
    return 1 if self.end_date_month == "January"
    return 2 if self.end_date_month == "February"
    return 3 if self.end_date_month == "March"
    return 4 if self.end_date_month == "April"
    return 5 if self.end_date_month == "May"
    return 6 if self.end_date_month == "June"
    return 7 if self.end_date_month == "July"
    return 8 if self.end_date_month == "August"
    return 9 if self.end_date_month == "September"
    return 10 if self.end_date_month == "October"
    return 11 if self.end_date_month == "November"
    return 12 if self.end_date_month == "December"
  end
end