class Patron
  class Retiree < Patron::Employee
    def user_group
    end

    def hr_criteria(hr_item)
      # this will need to be changed to exclude faculty
      true
    end

    def statistic_category
    end
    # def includable?
    # this will see if hr_data has anything
    # end
  end
end
