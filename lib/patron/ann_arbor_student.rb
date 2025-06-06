class Patron
  class AnnArborStudent < Patron::Student
    PCODE_PROG_STATISTIC_CATEGORY_MAP = {
      "U" => "UN",
      "G" => "GR",
      "GRAC" => "CD",
      "P" => "GR",
      "01363" => "UN",
      "01364" => "GR",
      "01365" => "UN",
      "01366" => "GR",
      "01367" => "UN",
      "01368" => "GR",
      "02059" => "UN",
      "02106" => "UN",
      "02116" => "GR",
      "02125" => "GR",
      "02114" => "GR",
      "02096" => "GR"
    }
    def term(termcode)
      # only use the first 3 characters of the term code to generate a number
      term_number = termcode[0, 3].to_i
      semesters = ["W", "SP", "SS", "SU", "F"]
      semester_index = (term_number - 2) % 5
      semester = semesters[semester_index]
      year = (term_number - 127) / 5
      "#{semester}#{year}"
    end

    def academic_program
      ldap_fields(@data["umichaaacadprogram"]).first
    end

    def user_group
      (statistic_category == "UN") ? "04" : "03"
    end

    def job_description
      academic_program.acadProgDescr
    end

    def statistic_category
      return "CD" if academic_program.acadCareer == "GRAC"
      pcode = academic_program.acadCareer[0]
      program_num = academic_program.acadProg
      pcode_prog = (pcode == "A") ? program_num : pcode
      PCODE_PROG_STATISTIC_CATEGORY_MAP[pcode_prog]
    end

    def includable?
      registered_or_candidate = ldap_fields(@data["umichaacurrenttermstatus"]).any? do |term|
        (term.regStatus == "RGSD" || term.acadCareer == "GRAC") && @current_schedule.includable_term?(term(term.termCode))
      end
      valid_academic_career = !statistic_category.nil?

      registered_or_candidate && valid_academic_career
    end
  end
end
