require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module ICU
  describe Federation do
    let(:total) { 193 } # This number has to be updated to be the number of elements in Federation.@@data

    context "#find using codes" do
      it "should find a federation given a valid code" do
        fed = Federation.find('IRL')
        expect(fed.code).to eq('IRL')
        expect(fed.name).to eq('Ireland')
      end

      it "should find a federation from code case insensitively" do
        fed = Federation.find('rUs')
        expect(fed.code).to eq('RUS')
        expect(fed.name).to eq('Russia')
      end

      it "should find a federation despite irrelevant whitespace" do
        fed = Federation.find('  mex    ')
        expect(fed.code).to eq('MEX')
        expect(fed.name).to eq('Mexico')
      end

      it "should return nil for an invalid code" do
        expect(Federation.find('XYZ')).to be_nil
      end
    end

    context "#find using names" do
      it "should find a federation given a valid name" do
        fed = Federation.find('England')
        expect(fed.code).to eq('ENG')
        expect(fed.name).to eq('England')
      end

      it "should find a federation from name case insensitively" do
        fed = Federation.find('franCE')
        expect(fed.code).to eq('FRA')
        expect(fed.name).to eq('France')
      end

      it "should not be fooled by irrelevant whitespace" do
        fed = Federation.find(' united  states  of  america ')
        expect(fed.code).to eq('USA')
        expect(fed.name).to eq('United States of America')
      end

      it "should return nil for an invalid name" do
        expect(Federation.find('Mordor')).to be_nil
      end
    end

    context "#find using parts of names" do
      it "should find a federation given a substring which is unique and at least 4 characters" do
        fed = Federation.find('bosni')
        expect(fed.code).to eq('BIH')
        expect(fed.name).to eq('Bosnia and Herzegovina')
      end

      it "should not be fooled by irrelevant whitespace" do
        fed = Federation.find('  arab    EMIRATES   ')
        expect(fed.code).to eq('UAE')
        expect(fed.name).to eq('United Arab Emirates')
      end

      it "should not find a federation if the substring matches more than one" do
        expect(Federation.find('land')).to be_nil
      end

      it "should return nil for any string smaller in length than 3" do
        expect(Federation.find('ze')).to be_nil
      end
    end

    context "#find federations with alternative names" do
      it "should find Macedonia multiple ways" do
        expect(Federation.find('MKD').name).to eq('Macedonia')
        expect(Federation.find('FYROM').name).to eq('Macedonia')
        expect(Federation.find('macedoni').name).to eq('Macedonia')
        expect(Federation.find('Macedonia').name).to eq('Macedonia')
        expect(Federation.find('former YUG Rep').name).to eq('Macedonia')
        expect(Federation.find('Republic of Macedonia').name).to eq('Macedonia')
        expect(Federation.find('former yugoslav republic').name).to eq('Macedonia')
      end
    end

    context "#find from common code errors" do
      it "should find IRL from ICU" do
        expect(Federation.find('ICU').code).to eq('IRL')
        expect(Federation.find('SPA').code).to eq('ESP')
        expect(Federation.find('WAL').code).to eq('WLS')
      end
    end

    context "#find with alternative inputs" do
      it "should behave robustly with completely invalid inputs" do
        expect(Federation.find()).to be_nil
        expect(Federation.find(nil)).to be_nil
        expect(Federation.find('')).to be_nil
        expect(Federation.find(1)).to be_nil
      end
    end

    context "#new is private" do
      it "#new cannot be called directly" do
        expect { Federation.new('IRL', 'Ireland') }.to raise_error(/private method/)
      end
    end

    context "documentation examples" do
      it "should all be correct for valid input" do
        expect(Federation.find('IRL').name).to eq('Ireland')
        expect(Federation.find('IRL').code).to eq('IRL')
        expect(Federation.find('rUs').code).to eq('RUS')
        expect(Federation.find('ongoli').name).to eq('Mongolia')
        expect(Federation.find('  united   states   ').code).to eq('USA')
      end

      it "should return nil for invalid input" do
        expect(Federation.find('ZYX')).to be_nil
        expect(Federation.find('land')).to be_nil
      end
    end

    context "#menu" do
      it "should return array of name-code pairs in order of name by default" do
        menu = Federation.menu
        expect(menu.size).to eq(total)
        names = menu.map{|m| m.first}.join(',')
        codes = menu.map{|m| m.last}.join(',')
        expect(names.index('Afghanistan')).to eq(0)
        expect(names.index('Iraq,Ireland,Israel')).not_to be_nil
        expect(codes.index('AFG')).to eq(0)
        expect(codes.index('IRQ,IRL,ISR')).not_to be_nil
      end

      it "should be configurable to order the list by codes" do
        menu = Federation.menu(:order => "code")
        expect(menu.size).to eq(total)
        names = menu.map{|m| m.first}.join(',')
        codes = menu.map{|m| m.last}.join(',')
        expect(names.index('Afghanistan')).to eq(0)
        expect(names.index('Ireland,Iraq,Iceland')).not_to be_nil
        expect(codes.index('AFG')).to eq(0)
        expect(codes.index('IRL,IRQ,ISL')).not_to be_nil
      end

      it "should be configurable to have a selected country at the top" do
        menu = Federation.menu(:top => 'IRL')
        expect(menu.size).to eq(total)
        names = menu.map{|m| m.first}.join(',')
        codes = menu.map{|m| m.last}.join(',')
        expect(names.index('Ireland,Afghanistan')).to eq(0)
        expect(names.index('Iraq,Israel')).not_to be_nil
        expect(codes.index('IRL,AFG')).to eq(0)
        expect(codes.index('IRQ,ISR')).not_to be_nil
      end

      it "should be configurable to have 'None' entry at the top" do
        menu = Federation.menu(:none => 'None')
        expect(menu.size).to eq(total + 1)
        names = menu.map{|m| m.first}.join(',')
        codes = menu.map{|m| m.last}.join(',')
        expect(names.index('None,Afghanistan')).to eq(0)
        expect(codes.index(',AFG')).to eq(0)
      end

      it "should be able to handle multiple configurations" do
        menu = Federation.menu(:top => 'IRL', :order => 'code', :none => 'None')
        expect(menu.size).to eq(total + 1)
        names = menu.map{|m| m.first}.join(',')
        codes = menu.map{|m| m.last}.join(',')
        expect(names.index('None,Ireland,Afghanistan')).to eq(0)
        expect(names.index('Iraq,Iceland')).not_to be_nil
        expect(codes.index(',IRL,AFG')).to eq(0)
        expect(codes.index('IRQ,ISL')).not_to be_nil
      end
    end

    context "#codes" do
      it "should return array of codes ordered alphabetically" do
        codes = Federation.codes
        expect(codes.size).to eq(total)
        all = codes.join(',')
        expect(all.index('AFG')).to eq(0)
        expect(all.index('INA,IND,IRI,IRL,IRQ,ISL,ISR,ISV,ITA,IVB')).not_to be_nil
      end
    end

  end
end
