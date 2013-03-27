# contains individual positions under experience in members profile
class Position < ActiveRecord::Base
  belongs_to :etkh_profile
  belongs_to :member_info

  attr_accessible :position,
        				  :organisation,
        				  :start_date_month,
        				  :start_date_year,
        				  :end_date_month,
        				  :end_date_year,
                  :current_position

  # if saved in etkh_profile also store position in member info table if it exists
  before_save do |position|
    if position.etkh_profile
      if position.etkh_profile.user.member_info
        member_info = position.etkh_profile.user.member_info
      else
        member_info = MemberInfo.new
        member_info.user_id = position.etkh_profile.user.id
        member_info.save
      end

      # store if position doesn't already exist in member info table
      member_info.positions.each do |p|
        if p.position == position.position && p.organisation == position.organisation
          # already exists
          return true
        end
      end
      position.member_info = member_info
    end
   end

   # don't destroy if position belongs to etkh_profile or member_info
   before_destroy do |position|
    if position.etkh_profile_id != nil || position.member_info_id != nil
      errors.add :base, "Must set both etkh_profile_id and member_info_id to nil before position can be destroyed"
      return false
    end
   end

  def self.custom_order(positions)
    # orders positions by year and then by month, with nil entries placed at top of list

    return positions if positions.length <= 1

    # create array of positions ordered by year
    ordered = []
    positions.order("end_date_year DESC").each do |pos|
      ordered << pos
    end

    ## sorting algorithm loops through all elements in array, collects elements with
    # the same end year in a separate array, removes these elements from the original
    # array, orders them within the separate array, and reinserts them back in the original array
    
    same_year_array = []

    # loop through all elements
    for i in 0..ordered.length-1
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

        # start of new year so reset
        current_year = ordered[i].end_date_year
        year_index = i
        same_year_array = []
      end
      
      # add element to array of same year elements
      same_year_array << ordered[i]
    end

    # need to order and reinsert the last set of same year elements
    if same_year_array && !same_year_array.empty?
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

  # gives a score for the month. Used in comparison of months in sorting algorithm
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