# class is used to generate a list of users with good profiles
# it contains results which can be easily queried or extended
class UsersSelection

  # constructor generates a list of users
  def initialize(list_length)
    # calls private method to perform algorithm
    @users = []
    gen_users(list_length)
  end

  # public method to generate users
  def generate_users(list_length)
    # calls private method to perform algorithm
    gen_users(list_length)
  end

  # gets additional users not already in list and adds to selection
  def generate_more_users(num)
    # users collection is automatically augmented in private method
    new_users = gen_users(num)

    # also return this latest selection
    return new_users
  end

  # accessor method for instance var
  def users
    return @users
  end


  private

  # define minimum requirements
  MIN_PROFILE_COMPLETENESS = 50
  MIN_BACKGROUND_LENGTH = 500
  PROBABILITY_MIN_PROFILE = 0.50

  # algorithm for generating users
  # returns an array of users
  def gen_users(list_length)
    new_selection = []

    # get all users
    all_users = User.all

    # shuffle them randomly
    shuffled_users = all_users.shuffle

    # cycle through all users randomly
    shuffled_users.each do |user|
      # check user profile isn't already in current selection
      if !@users.include?(user)
        # check user profile exists
        if user.etkh_profile
          profile_completeness = user.etkh_profile.get_profile_completeness

          # check user profile meets minimum requirements        
          if profile_completeness >= MIN_PROFILE_COMPLETENESS && user.avatar? \
            && user.etkh_profile.background.length >= MIN_BACKGROUND_LENGTH

            # insert randomness and bias towards profiles with high completeness
            r = Random.new
            rand = r.rand(1..10)  # random integer between 1 and 10
            product = rand * profile_completeness
            
            # threshold is defined by the probability that a profile with min profile completeness
            # will be selected
            
            max_product = MIN_PROFILE_COMPLETENESS * 10
            threshold = (1 - PROBABILITY_MIN_PROFILE) * max_product

            if product >= threshold
                # add to total list
                @users << user

                # add to list of latest selection
                new_selection << user
            end
          end
        end
      end

      # exit loop if enough users have been found
      break if new_selection.length >= list_length
    end
    
    # return this selection
    return new_selection
  end
end