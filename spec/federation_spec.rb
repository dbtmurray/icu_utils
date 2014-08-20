require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module ICU
  describe Federation do
    let(:total) { 181 }

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

      it "should be configuarble to order the list by codes" do
        menu = Federation.menu(:order => "code")
        expect(menu.size).to eq(total)
        names = menu.map{|m| m.first}.join(',')
        codes = menu.map{|m| m.last}.join(',')
        expect(names.index('Afghanistan')).to eq(0)
        expect(names.index('Ireland,Iraq,Iceland')).not_to be_nil
        expect(codes.index('AFG')).to eq(0)
        expect(codes.index('IRL,IRQ,ISL')).not_to be_nil
      end

      it "should be configuarble to have a selected country at the top" do
        menu = Federation.menu(:top => 'IRL')
        expect(menu.size).to eq(total)
        names = menu.map{|m| m.first}.join(',')
        codes = menu.map{|m| m.last}.join(',')
        expect(names.index('Ireland,Afghanistan')).to eq(0)
        expect(names.index('Iraq,Israel')).not_to be_nil
        expect(codes.index('IRL,AFG')).to eq(0)
        expect(codes.index('IRQ,ISR')).not_to be_nil
      end

      it "should be configuarble to have 'None' entry at the top" do
        menu = Federation.menu(:none => 'None')
        expect(menu.size).to eq(total + 1)
        names = menu.map{|m| m.first}.join(',')
        codes = menu.map{|m| m.last}.join(',')
        expect(names.index('None,Afghanistan')).to eq(0)
        expect(codes.index(',AFG')).to eq(0)
      end

      it "should be able to handle multiple configuarations" do
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

    context "IOC codes" do
      before(:all) do
        ioc_and_fide = # from http://en.wikipedia.org/wiki/List_of_IOC_country_codes in November 2013
        {
          "AFG" => "Afghanistan",
          "AHO" => "Netherlands Antilles",
          "ALB" => "Albania",
          "ALG" => "Algeria",
          "AND" => "Andorra",
          "ANG" => "Angola",
          "ANT" => "Antigua and Barbuda",
          "ARG" => "Argentina",
          "ARM" => "Armenia",
          "ARU" => "Aruba",
          "AUS" => "Australia",
          "AUT" => "Austria",
          "AZE" => "Azerbaijan",
          "BAH" => "Bahamas",
          "BAN" => "Bangladesh",
          "BAR" => "Barbados",
          "BDI" => "Burundi",
          "BEL" => "Belgium",
          "BEN" => "Benin",
          "BER" => "Bermuda",
          "BHU" => "Bhutan",
          "BIH" => "Bosnia and Herzegovina",
          "BIZ" => "Belize",
          "BLR" => "Belarus",
          "BOL" => "Bolivia",
          "BOT" => "Botswana",
          "BRA" => "Brazil",
          "BRN" => "Bahrain",
          "BRU" => "Brunei",
          "BUL" => "Bulgaria",
          "CAM" => "Cambodia",
          "CAN" => "Canada",
          "CGO" => "Congo",
          "CHA" => "Chad",
          "CHI" => "Chile",
          "CHN" => "China",
          "CIV" => "Ivory Coast",
          "CMR" => "Cameroon",
          "COL" => "Colombia",
          "CRC" => "Costa Rica",
          "CRO" => "Croatia",
          "CUB" => "Cuba",
          "CYP" => "Cyprus",
          "CZE" => "Czech Republic",
          "DEN" => "Denmark",
          "DJI" => "Djibouti",
          "DOM" => "Dominican Republic",
          "ECU" => "Ecuador",
          "EGY" => "Egypt",
          "ESA" => "El Salvador",
          "ESP" => "Spain",
          "EST" => "Estonia",
          "ETH" => "Ethiopia",
          "FIJ" => "Fiji",
          "FIN" => "Finland",
          "FRA" => "France",
          "FRO" => "Faroe Islands",
          "GAB" => "Gabon",
          "GAM" => "The Gambia",
          "GEO" => "Georgia",
          "GER" => "Germany",
          "GHA" => "Ghana",
          "GRE" => "Greece",
          "GUA" => "Guatemala",
          "GUM" => "Guam",
          "GUY" => "Guyana",
          "HAI" => "Haiti",
          "HKG" => "Hong Kong",
          "HON" => "Honduras",
          "HUN" => "Hungary",
          "INA" => "Indonesia",
          "IND" => "India",
          "IRI" => "Iran",
          "IRL" => "Ireland",
          "IRQ" => "Iraq",
          "ISL" => "Iceland",
          "ISR" => "Israel",
          "ISV" => "Virgin Islands",
          "ITA" => "Italy",
          "IVB" => "British Virgin Islands",
          "JAM" => "Jamaica",
          "JOR" => "Jordan",
          "JPN" => "Japan",
          "KAZ" => "Kazakhstan",
          "KEN" => "Kenya",
          "KGZ" => "Kyrgyzstan",
          "KOR" => "South Korea",
          "KSA" => "Saudi Arabia",
          "KUW" => "Kuwait",
          "LAO" => "Laos",
          "LAT" => "Latvia",
          "LBA" => "Libya",
          "LES" => "Lesotho",
          "LIB" => "Lebanon",
          "LIE" => "Liechtenstein",
          "LTU" => "Lithuania",
          "LUX" => "Luxembourg",
          "MAC" => "Macau",
          "MAD" => "Madagascar",
          "MAR" => "Morocco",
          "MAS" => "Malaysia",
          "MAW" => "Malawi",
          "MDA" => "Moldova",
          "MDV" => "Maldives",
          "MEX" => "Mexico",
          "MGL" => "Mongolia",
          "MKD" => "Macedonia",
          "MLI" => "Mali",
          "MLT" => "Malta",
          "MNE" => "Montenegro",
          "MON" => "Monaco",
          "MOZ" => "Mozambique",
          "MRI" => "Mauritius",
          "MTN" => "Mauritania",
          "MYA" => "Myanmar",
          "NAM" => "Namibia",
          "NCA" => "Nicaragua",
          "NED" => "Netherlands",
          "NEP" => "Nepal",
          "NGR" => "Nigeria",
          "NOR" => "Norway",
          "NZL" => "New Zealand",
          "PAK" => "Pakistan",
          "PAN" => "Panama",
          "PAR" => "Paraguay",
          "PER" => "Peru",
          "PHI" => "Philippines",
          "PLE" => "Palestine",
          "PLW" => "Palau",
          "PNG" => "Papua New Guinea",
          "POL" => "Poland",
          "POR" => "Portugal",
          "PUR" => "Puerto Rico",
          "QAT" => "Qatar",
          "ROU" => "Romania",
          "RSA" => "South Africa",
          "RUS" => "Russia",
          "RWA" => "Rwanda",
          "SEN" => "Senegal",
          "SEY" => "Seychelles",
          "SIN" => "Singapore",
          "SLE" => "Sierra Leone",
          "SLO" => "Slovenia",
          "SMR" => "San Marino",
          "SOL" => "Solomon Islands",
          "SOM" => "Somalia",
          "SRB" => "Serbia",
          "SRI" => "Sri Lanka",
          "STP" => "Sao Tome and Principe",
          "SUD" => "Sudan",
          "SUI" => "Switzerland",
          "SUR" => "Suriname",
          "SVK" => "Slovakia",
          "SWE" => "Sweden",
          "SWZ" => "Swaziland",
          "SYR" => "Syria",
          "TAN" => "Tanzania",
          "THA" => "Thailand",
          "TJK" => "Tajikistan",
          "TKM" => "Turkmenistan",
          "TOG" => "Togo",
          "TPE" => "Chinese Taipei",
          "TRI" => "Trinidad and Tobago",
          "TUN" => "Tunisia",
          "TUR" => "Turkey",
          "UAE" => "United Arab Emirates",
          "UGA" => "Uganda",
          "UKR" => "Ukraine",
          "URU" => "Uruguay",
          "USA" => "United States",
          "UZB" => "Uzbekistan",
          "VEN" => "Venezuela",
          "VIE" => "Vietnam",
          "YEM" => "Yemen",
          "ZAM" => "Zambia",
          "ZIM" => "Zimbabwe",
        }
        ioc_but_not_fide =
        {
          "ASA" => "American Samoa",
          "BUR" => "Burkina Faso",
          "CAF" => "Central African Republic",
          "CAY" => "Cayman Islands",
          "COD" => "DR Congo",
          "COK" => "Cook Islands",
          "COM" => "Comoros",
          "CPV" => "Cape Verde",
          "DMA" => "Dominica",
          "ERI" => "Eritrea",
          "FSM" => "Federated States of Micronesia",
          "GBR" => "Great Britain",
          "GBS" => "Guinea-Bissau",
          "GEQ" => "Equatorial Guinea",
          "GRN" => "Grenada",
          "GUI" => "Guinea",
          "KIR" => "Kiribati",
          "LBR" => "Liberia",
          "LCA" => "Saint Lucia",
          "MHL" => "Marshall Islands",
          "NIG" => "Niger",
          "NRU" => "Nauru",
          "OMA" => "Oman",
          "PRK" => "North Korea",
          "SAM" => "Samoa",
          "SKN" => "Saint Kitts and Nevis",
          "TGA" => "Tonga",
          "TLS" => "Timor-Leste",
          "TUV" => "Tuvalu",
          "VAN" => "Vanuatu",
          "VIN" => "Saint Vincent and the Grenadines",
        }
        @missing = []
        @badname = []
        british = %w[ENG SCO WLS GCI JCI]
        exceptions = # FIDE => IOC
        {
          "FAI" => "FRO", # Faroe Islands
          "MNC" => "MON", # Monaco
        }
        got = {}
        Federation.menu.each do |name, code|
          if ioc_and_fide[code]
            @badname << "#{code} #{name} #{ioc_and_fide[code]}" unless ioc_and_fide[code].include?(name) || name.include?(ioc_and_fide[code])
          else
            @missing << code unless british.include?(code) || exceptions.keys.include?(code)
          end
          got[code] = true
        end
        @not_included = ioc_and_fide.keys.reject { |code| got[code] || exceptions.values.include?(code) }
      end

      it "codes should be all IOC with some exceptions" do
        expect(@missing.join("|")).to eq ""
      end

      it "country names should be similar to the IOC name" do
        expect(@badname.join("|")).to eq ""
      end

      it "all IOC codes that are FIDE members should be present" do
        expect(@not_included.join("|")).to eq ""
      end
    end
  end
end
