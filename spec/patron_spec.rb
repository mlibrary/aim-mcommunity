describe Patron do
  before(:each) do
    @patron = json_fixture("emcard_staff.json")
    @name_double = instance_double(Name, first_name: "Emily", middle_name: "O", last_name: "Card", middle_name?: true)
  end
  subject do
    described_class.new(data: @patron, name: @name_double)
  end
  it "returns record_type" do
    # this is static
    expect(subject.record_type).to eq("PUBLIC")
  end
  it "returns external_id" do
    # this is static
    expect(subject.external_id).to eq("SIS")
  end
  it "returns a primary_id" do
    expect(subject.primary_id).to eq("emcard")
  end
  it "returns a first_name" do
    expect(subject.first_name).to eq("Emily")
  end
  it "returns a last_name" do
    expect(subject.last_name).to eq("Card")
  end
  it "returns a middle_name" do
    expect(subject.middle_name).to eq("O")
  end
  it "returns true if a middle name exists" do
    expect(subject.middle_name?).to eq(true)
  end
  it "returns not implemented error for campus_code" do
    expect { subject.campus_code }.to raise_error(NotImplementedError)
  end
  it "returns not implemented error for user_group" do
    expect { subject.campus_code }.to raise_error(NotImplementedError)
  end
  it "returns not implemented error for email_type" do
    expect { subject.email_type }.to raise_error(NotImplementedError)
  end
  it "returns an email_address" do
    expect(subject.email_address).to eq("emcard@umich.edu")
  end
  xcontext "#telephone_number" do
    it "returns the first telephoneNumber if there is one" do
      @patron["telephoneNumber"].push("someotherphone number")
      @patron["umichpermanentphone"] = ["my-umich-permanent-phone-number", "second-number"]
      expect(subject.telephone_number).to eq("734-999-9999")
    end
    it "returns umichPermanetnPhone if there is no telephonNumber" do
      @patron.delete("telephonenumber")
      @patron["umichPermanentPhone"] = ["my-umich-permanent-phone-number", "second-number"]
      expect(subject.telephone_number).to eq("my-umich-permanent-phone-number")
    end
  end
  it "returns a status_date"
  it "returns an expiry_date"
  it "returns a purge_date"
  it "returns not implemented error for job_description" do
    expect { subject.job_description }.to raise_error(NotImplementedError)
  end
  it "returns not implemented error for statistic_category" do
    expect { subject.stastic_category }.to raise_error(NotImplementedError)
  end
  context "#base_inst_role" do
    it "returns the correct heirarchical inst role" do
      @patron["umichinstroles"].push("FacultyAA")
      expect(subject.base_inst_role["role"]).to eq("faculty")
      expect(subject.base_inst_role["campus"]).to eq("UMAA")
    end
  end
  context "addresses" do
    # this is here because Patron doesn't implement umich_address_type
    let(:staff_person) { StaffPerson.new(data: @patron, name: @name_double) }
    context "#umich_address" do
      before(:each) do
        second_work_address = "{addr1=Somewhere Else}:{addr2=300 Hatcher North}:{city=Ann Arbor}:{state=MI}:{postal=48109-1190}:{nation=UNITED STATES}:{nationCode=USA}"
        second_home_address = "{city=Ann Arbor}:{state=MI}:{postal=48105}:{nation=UNITED STATES}:{nationCode=USA}"
        @patron["umichpostaladdressdata"].push(second_work_address)
        @patron["umichhomepostaladdressdata"].push(second_home_address)
      end

      it "returns a umichpostaladdressdata if it exists" do
        expect(staff_person.umich_address.line1).to eq("Library Info Tech - AIM")
      end
      it "returns the first umichhomepostaladdress if there's no umichpostaladdressdata" do
        @patron.delete("umichpostaladdressdata")
        expect(staff_person.umich_address.line1).to eq "1111 Pear Street"
      end
      it "returns nil if there's none of these" do
        @patron.delete("umichpostaladdressdata")
        @patron.delete("umichhomepostaladdressdata")
        expect(staff_person.umich_address).to be_nil
      end
      xit "has all of the expected values for an address" do
        address = staff_person.umich_addresst
        expect(address.line1).to eq "Library Info Tech - AIM"
        expect(address.line2).to eq "300 Hatcher North"
        expect(address.city).to eq "Ann Arbor"
        expect(address.state_province).to eq "MI"
        expect(address.postal_code).to eq "48109-1190"
        expect(address.country).to eq "UNITED STATES"
      end
      it "shows '(no address)' when theres no addr1" do
        @patron["umichpostaladdressdata"].first.sub!(/{addr1=.*}/, "")
        expect(staff_person.umich_address.line1).to eq("(no address)")
      end
      it "shows the aprropriate umich_address_type" do
        expect(staff_person.umich_address.type).to eq("work")
      end
    end
    context "#permanent_address" do
      before(:each) do
        second_permanent_address = "{addr1=Somewhere Else}:{addr2=300 Hatcher North}:{city=Ann Arbor}:{state=MI}:{postal=48109-1190}:{nation=UNITED STATES}:{nationCode=USA}"
        second_home_address = "{city=Ann Arbor}:{state=MI}:{postal=48105}:{nation=UNITED STATES}:{nationCode=USA}"
        @patron["umichpermanentpostaladdressdata"].push(second_permanent_address)
        @patron["umichhomepostaladdressdata"].push(second_home_address)
      end

      it "returns a umichpermanentpostaladdressdata if it exists" do
        expect(staff_person.permanent_address.line1).to eq("1111 Pear Trail")
      end
      it "returns the first umichhomepostaladdress if there's no umichpostaladdressdata" do
        @patron.delete("umichpermanentpostaladdressdata")
        expect(staff_person.permanent_address.line1).to eq "1111 Pear Street"
      end
      it "returns nil if there's none of these" do
        @patron.delete("umichpermanentpostaladdressdata")
        @patron.delete("umichhomepostaladdressdata")
        expect(staff_person.permanent_address).to be_nil
      end
      it "shows the aprropriate home for address type" do
        expect(staff_person.permanent_address.type).to eq("home")
      end
    end
    context "#addresses" do
      it "returns an array of addresses" do
        expect(staff_person.addresses.count).to eq(2)
      end
      it "returns the first one as preferred" do
        expect(staff_person.addresses.first.preferred).to eq(true)
        expect(staff_person.addresses[1].preferred).to eq(false)
      end
      it "returns the first as preferred if it's the only address" do
        @patron.delete("umichpostaladdressdata")
        @patron.delete("umichhomepostaladdressdata")
        expect(staff_person.addresses.first.preferred).to eq(true)
        expect(staff_person.addresses.count).to eq(1)
      end
    end
  end
end
