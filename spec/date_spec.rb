require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module ICU
  describe Date do
    let(:penny)     { ::Date.new(1986, 6, 16) }
    let(:mark)      { ::Date.new(1955, 11, 9) }
    let(:today)     { ::Date.today }
    let(:yesterday) { ::Date.today - 1 }

    context "no constraints" do
      it "today" do
        d = ICU::Date.new(today)
        expect(d).to be_valid
        expect(d.date).to eq today
        expect(d.reasons).to be_empty
      end

      it "now" do
        d = ICU::Date.new(Time.now)
        expect(d).to be_valid
        expect(d.date).to eq today
        expect(d.reasons).to be_empty
      end

      it "human" do
        d = ICU::Date.new("9th November 1955")
        expect(d).to be_valid
        expect(d.date).to eq mark
        expect(d.reasons).to be_empty
      end

      it "abbreviated" do
        d = ICU::Date.new("June 16 1986")
        expect(d).to be_valid
        expect(d.date).to eq penny
        expect(d.reasons).to be_empty
      end

      it "invalid" do
        d = ICU::Date.new("rubbish")
        expect(d).to_not be_valid
        expect(d.reasons).to_not be_empty
        expect(d.reasons.size).to eq 1
        expect(d.reasons.first).to eq "errors.messages.invalid_date"
      end

      it "impossible" do
        d = ICU::Date.new("2014-02-30")
        expect(d).to_not be_valid
        expect(d.reasons).to_not be_empty
        expect(d.reasons.size).to eq 1
        expect(d.reasons.first).to eq "errors.messages.invalid_date"
      end
    end

    context "after" do
      it "today/yesterday" do
        d = ICU::Date.new(today, after: yesterday)
        expect(d).to be_valid
        expect(d.date).to eq today
        expect(d.reasons).to be_empty
      end

      it "yesterday/today" do
        d = ICU::Date.new(yesterday, after: today)
        expect(d).to_not be_valid
        expect(d.date).to eq yesterday
        expect(d.reasons[0]).to eq "errors.messages.after"
        expect(d.reasons[1]).to eq restriction: today.to_s
      end

      it "today/today" do
        d = ICU::Date.new(today, after: today)
        expect(d).to_not be_valid
        expect(d.date).to eq today
        expect(d.reasons[0]).to eq "errors.messages.after"
        expect(d.reasons[1]).to eq restriction: today.to_s
      end

      it "invalid" do
        expect{ICU::Date.new(today, after: "rubbish")}.to raise_error(/invalid/)
      end
    end

    context "on or after" do
      it "today/yesterday" do
        d = ICU::Date.new(today, on_or_after: yesterday)
        expect(d).to be_valid
        expect(d.date).to eq today
        expect(d.reasons).to be_empty
      end

      it "yesterday/today" do
        d = ICU::Date.new(yesterday, on_or_after: today)
        expect(d).to_not be_valid
        expect(d.date).to eq yesterday
        expect(d.reasons[0]).to eq "errors.messages.on_or_after"
        expect(d.reasons[1]).to eq restriction: today.to_s
      end

      it "today/today" do
        d = ICU::Date.new(today, on_or_after: today)
        expect(d).to be_valid
        expect(d.date).to eq today
        expect(d.reasons).to be_empty
      end

      it "impossible" do
        expect{ICU::Date.new(today, on_or_after: ::Date.new(1955, 2, 29))}.to raise_error(/invalid/)
      end
    end

    context "before" do
      it "yesterday/today" do
        d = ICU::Date.new(yesterday, before: today)
        expect(d).to be_valid
        expect(d.date).to eq yesterday
        expect(d.reasons).to be_empty
      end

      it "today/yesterday" do
        d = ICU::Date.new(today, before: yesterday)
        expect(d).to_not be_valid
        expect(d.date).to eq today
        expect(d.reasons[0]).to eq "errors.messages.before"
        expect(d.reasons[1]).to eq restriction: yesterday.to_s
      end

      it "today/today" do
        d = ICU::Date.new(today, before: today.to_s)
        expect(d).to_not be_valid
        expect(d.date).to eq today
        expect(d.reasons[0]).to eq "errors.messages.before"
        expect(d.reasons[1]).to eq restriction: today.to_s
      end

      it "invalid" do
        expect{ICU::Date.new(today, before: "")}.to raise_error(/invalid/)
      end
    end

    context "on or before" do
      it "yesterday/today" do
        d = ICU::Date.new(yesterday, on_or_before: today.to_s)
        expect(d).to be_valid
        expect(d.date).to eq yesterday
        expect(d.reasons).to be_empty
      end

      it "today/yesterday" do
        d = ICU::Date.new(today, on_or_before: yesterday)
        expect(d).to_not be_valid
        expect(d.date).to eq today
        expect(d.reasons[0]).to eq "errors.messages.on_or_before"
        expect(d.reasons[1]).to eq restriction: yesterday.to_s
      end

      it "today/today" do
        d = ICU::Date.new(today, on_or_before: today)
        expect(d).to be_valid
        expect(d.date).to eq today
        expect(d.reasons).to be_empty
      end

      it "impossible" do
        expect{ICU::Date.new(today, on_or_before: "2014-06-31")}.to raise_error(/invalid/)
      end
    end

    context "multiple constraints" do
      it "today/today" do
        d = ICU::Date.new(today, on_or_after: today.to_s, on_or_before: today)
        expect(d).to be_valid
        expect(d.date).to eq today
        expect(d.reasons).to be_empty
      end
    end

    context "proc constraints" do
      it "before" do
        d = ICU::Date.new(penny, before: -> { ::Date.today })
        expect(d).to be_valid
        expect(d.date).to eq penny
        expect(d.reasons).to be_empty
      end

      it "after" do
        d = ICU::Date.new(yesterday, after: -> { ::Date.today })
        expect(d).to_not be_valid
        expect(d.date).to eq yesterday
        expect(d.reasons[0]).to eq "errors.messages.after"
        expect(d.reasons[1]).to eq restriction: today.to_s
      end

      it "on or before" do
        d = ICU::Date.new(today, on_or_before: -> { ::Date.today - 1 })
        expect(d).to_not be_valid
        expect(d.date).to eq today
        expect(d.reasons[0]).to eq "errors.messages.on_or_before"
        expect(d.reasons[1]).to eq restriction: yesterday.to_s
      end

      it "on or after" do
        d = ICU::Date.new(mark, on_or_after: -> { ::Date.new(1986, 6, 16) })
        expect(d).to_not be_valid
        expect(d.date).to eq mark
        expect(d.reasons[0]).to eq "errors.messages.on_or_after"
        expect(d.reasons[1]).to eq restriction: penny.to_s
      end
    end

    context "symbol constraints" do
      it "before" do
        d = ICU::Date.new(penny, before: :today)
        expect(d).to be_valid
        expect(d.date).to eq penny
        expect(d.reasons).to be_empty
      end

      it "after" do
        d = ICU::Date.new(yesterday, after: "TODAY")
        expect(d).to_not be_valid
        expect(d.date).to eq yesterday
        expect(d.reasons[0]).to eq "errors.messages.after"
        expect(d.reasons[1]).to eq restriction: today.to_s
      end

      it "on or before" do
        d = ICU::Date.new(today, on_or_before: "Today")
        expect(d).to be_valid
        expect(d.date).to eq today
        expect(d.reasons).to be_empty
      end

      it "on or after" do
        d = ICU::Date.new(mark, on_or_after: "today")
        expect(d).to_not be_valid
        expect(d.date).to eq mark
        expect(d.reasons[0]).to eq "errors.messages.on_or_after"
        expect(d.reasons[1]).to eq restriction: today.to_s
      end
    end
  end
end
