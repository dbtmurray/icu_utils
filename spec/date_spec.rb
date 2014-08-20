require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module ICU
  describe Date do
    context "no constraints" do
      it "today" do
        today = ICU::Date.new(::Date.today)
        expect(today).to be_valid
        expect(today.date).to eq ::Date.today
        expect(today.reasons).to be_empty
      end

      it "now" do
        now = ICU::Date.new(Time.now)
        expect(now).to be_valid
        expect(now.date).to eq ::Date.today
        expect(now.reasons).to be_empty
      end

      it "human" do
        now = ICU::Date.new("9th November 1955")
        expect(now).to be_valid
        expect(now.date).to eq ::Date.new(1955, 11, 9)
        expect(now.reasons).to be_empty
      end

      it "abbreviated" do
        now = ICU::Date.new("June 16 1986")
        expect(now).to be_valid
        expect(now.date).to eq ::Date.new(1986, 6, 16)
        expect(now.reasons).to be_empty
      end

      it "invalid" do
        invalid = ICU::Date.new("rubbish")
        expect(invalid).to_not be_valid
        expect(invalid.reasons).to_not be_empty
        expect(invalid.reasons.size).to eq 1
        expect(invalid.reasons.first).to eq "errors.messages.invalid_date"
      end

      it "impossible" do
        invalid = ICU::Date.new("2014-02-30")
        expect(invalid).to_not be_valid
        expect(invalid.reasons).to_not be_empty
        expect(invalid.reasons.size).to eq 1
        expect(invalid.reasons.first).to eq "errors.messages.invalid_date"
      end
    end

    context "after" do
      it "today/yesterday" do
        d = ICU::Date.new(::Date.today, after: ::Date.today - 1)
        expect(d).to be_valid
        expect(d.date).to eq ::Date.today
        expect(d.reasons).to be_empty
      end

      it "yesterday/today" do
        d = ICU::Date.new(::Date.today - 1, after: ::Date.today)
        expect(d).to_not be_valid
        expect(d.date).to eq ::Date.today - 1
        expect(d.reasons[0]).to eq "errors.messages.after"
        expect(d.reasons[1]).to eq restriction: ::Date.today.to_s
      end

      it "today/today" do
        d = ICU::Date.new(::Date.today, after: ::Date.today)
        expect(d).to_not be_valid
        expect(d.date).to eq ::Date.today
        expect(d.reasons[0]).to eq "errors.messages.after"
        expect(d.reasons[1]).to eq restriction: ::Date.today.to_s
      end

      it "invalid" do
        expect{ICU::Date.new(::Date.today, after: "rubbish")}.to raise_error(/invalid/)
      end
    end

    context "on or after" do
      it "today/yesterday" do
        d = ICU::Date.new(::Date.today, on_or_after: ::Date.today - 1)
        expect(d).to be_valid
        expect(d.date).to eq ::Date.today
        expect(d.reasons).to be_empty
      end

      it "yesterday/today" do
        d = ICU::Date.new(::Date.today - 1, on_or_after: ::Date.today)
        expect(d).to_not be_valid
        expect(d.date).to eq ::Date.today - 1
        expect(d.reasons[0]).to eq "errors.messages.on_or_after"
        expect(d.reasons[1]).to eq restriction: ::Date.today.to_s
      end

      it "today/today" do
        d = ICU::Date.new(::Date.today, on_or_after: ::Date.today)
        expect(d).to be_valid
        expect(d.date).to eq ::Date.today
        expect(d.reasons).to be_empty
      end

      it "impossible" do
        expect{ICU::Date.new(::Date.today, on_or_after: ::Date.new(1955, 2, 29))}.to raise_error(/invalid/)
      end
    end

    context "before" do
      it "yesterday/today" do
        d = ICU::Date.new(::Date.today - 1, before: ::Date.today)
        expect(d).to be_valid
        expect(d.date).to eq ::Date.today - 1
        expect(d.reasons).to be_empty
      end

      it "today/yesterday" do
        d = ICU::Date.new(::Date.today, before: ::Date.today - 1)
        expect(d).to_not be_valid
        expect(d.date).to eq ::Date.today
        expect(d.reasons[0]).to eq "errors.messages.before"
        expect(d.reasons[1]).to eq restriction: (::Date.today - 1).to_s
      end

      it "today/today" do
        d = ICU::Date.new(::Date.today, before: ::Date.today.to_s)
        expect(d).to_not be_valid
        expect(d.date).to eq ::Date.today
        expect(d.reasons[0]).to eq "errors.messages.before"
        expect(d.reasons[1]).to eq restriction: ::Date.today.to_s
      end

      it "invalid" do
        expect{ICU::Date.new(::Date.today, before: "")}.to raise_error(/invalid/)
      end
    end

    context "on or before" do
      it "yesterday/today" do
        d = ICU::Date.new(::Date.today - 1, on_or_before: ::Date.today.to_s)
        expect(d).to be_valid
        expect(d.date).to eq ::Date.today - 1
        expect(d.reasons).to be_empty
      end

      it "today/yesterday" do
        d = ICU::Date.new(::Date.today, on_or_before: ::Date.today - 1)
        expect(d).to_not be_valid
        expect(d.date).to eq ::Date.today
        expect(d.reasons[0]).to eq "errors.messages.on_or_before"
        expect(d.reasons[1]).to eq restriction: (::Date.today - 1).to_s
      end

      it "today/today" do
        d = ICU::Date.new(::Date.today, on_or_before: ::Date.today)
        expect(d).to be_valid
        expect(d.date).to eq ::Date.today
        expect(d.reasons).to be_empty
      end

      it "impossible" do
        expect{ICU::Date.new(::Date.today, on_or_before: "2014-06-31")}.to raise_error(/invalid/)
      end
    end
  end

  context "multiple constraints" do
    it "today/today" do
      d = ICU::Date.new(::Date.today, on_or_after: ::Date.today.to_s, on_or_before: ::Date.today)
      expect(d).to be_valid
      expect(d.date).to eq ::Date.today
      expect(d.reasons).to be_empty
    end
  end
end
