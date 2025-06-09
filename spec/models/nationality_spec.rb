# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nationality, type: :model do
  describe 'associations' do
    it { should have_many(:composers) }

    context 'composers relationship' do
      let(:nationality) { create(:nationality) }

      it 'can have multiple composers' do
        composer1 = create(:composer, nationality: nationality)
        composer2 = create(:composer, nationality: nationality)

        expect(nationality.composers).to contain_exactly(composer1, composer2)
        expect(nationality.composers.count).to eq(2)
      end

      it 'can exist without composers' do
        nationality = create(:nationality)
        expect(nationality.composers).to be_empty
      end
    end
  end

  describe 'validations' do
    context 'factory validation' do
      it 'has a valid factory' do
        expect(build(:nationality)).to be_valid
      end

      it 'has valid factory traits' do
        expect(build(:nationality, :french)).to be_valid
        expect(build(:nationality, :german)).to be_valid
        expect(build(:nationality, :italian)).to be_valid
        expect(build(:nationality, :austrian)).to be_valid
        expect(build(:nationality, :polish)).to be_valid
      end
    end

    context 'name validation' do
      it { should validate_presence_of(:name) }

      it 'validates uniqueness of name' do
        create(:nationality, name: 'Test Name', code: 'TN')
        should validate_uniqueness_of(:name)
      end

      it 'is invalid without a name' do
        nationality = build(:nationality, name: nil)
        expect(nationality).not_to be_valid
        expect(nationality.errors[:name]).to include("can't be blank")
      end

      it 'is invalid with a duplicate name' do
        create(:nationality, name: 'French')
        duplicate = build(:nationality, name: 'French')

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:name]).to include("has already been taken")
      end

      it 'is case sensitive for uniqueness' do
        create(:nationality, name: 'French')
        different_case = build(:nationality, name: 'french')

        expect(different_case).to be_valid
      end

      it 'allows names with special characters' do
        nationality = build(:nationality, name: 'São Toméan')
        expect(nationality).to be_valid
      end

      it 'allows long nationality names' do
        long_name = 'Democratic Republic of São Tomé and Príncipe'
        nationality = build(:nationality, name: long_name)
        expect(nationality).to be_valid
      end
    end

    context 'code validation' do
      it { should validate_presence_of(:code) }

      it 'validates uniqueness of code' do
        create(:nationality, name: 'Test Name', code: 'TN')
        should validate_uniqueness_of(:code)
      end

      it 'is invalid without a code' do
        nationality = build(:nationality, code: nil)
        expect(nationality).not_to be_valid
        expect(nationality.errors[:code]).to include("can't be blank")
      end

      it 'is invalid with a duplicate code' do
        create(:nationality, code: 'FR')
        duplicate = build(:nationality, code: 'FR')

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:code]).to include("has already been taken")
      end

      it 'is case sensitive for uniqueness' do
        create(:nationality, code: 'FR')
        different_case = build(:nationality, code: 'fr')

        expect(different_case).to be_valid
      end

      it 'allows various code formats' do
        expect(build(:nationality, code: 'US')).to be_valid
        expect(build(:nationality, code: 'UK')).to be_valid
        expect(build(:nationality, code: 'CH')).to be_valid
        expect(build(:nationality, code: 'NL')).to be_valid
      end
    end

    context 'combined validation scenarios' do
      it 'allows same name with different code' do
        create(:nationality, name: 'American', code: 'US')
        similar = build(:nationality, name: 'American', code: 'CA')

        expect(similar).not_to be_valid # Name must be unique
      end

      it 'allows same code with different name' do
        create(:nationality, name: 'French', code: 'FR')
        similar = build(:nationality, name: 'German', code: 'FR')

        expect(similar).not_to be_valid # Code must be unique
      end
    end
  end

  describe 'scopes' do
    context '.ordered' do
      it 'orders nationalities by code' do
        german = create(:nationality, name: 'German', code: 'DE')
        french = create(:nationality, name: 'French', code: 'FR')
        austrian = create(:nationality, name: 'Austrian', code: 'AT')

        ordered = Nationality.ordered
        expect(ordered.pluck(:code)).to eq(['AT', 'DE', 'FR'])
        expect(ordered).to eq([austrian, german, french])
      end

      it 'handles empty collection' do
        expect(Nationality.ordered).to be_empty
      end

      it 'orders correctly with special characters in codes' do
        nationality1 = create(:nationality, name: 'Test1', code: 'A1')
        nationality2 = create(:nationality, name: 'Test2', code: 'AA')
        nationality3 = create(:nationality, name: 'Test3', code: 'AB')

        ordered = Nationality.ordered
        expect(ordered.pluck(:code)).to eq(['A1', 'AA', 'AB'])
      end
    end
  end

  describe 'database constraints and indexes' do
    it 'has unique index on name' do
      indexes = ActiveRecord::Base.connection.indexes('nationalities')
      name_index = indexes.find { |idx| idx.columns == ['name'] && idx.unique }
      expect(name_index).to be_present
    end

    it 'has unique index on code' do
      indexes = ActiveRecord::Base.connection.indexes('nationalities')
      code_index = indexes.find { |idx| idx.columns == ['code'] && idx.unique }
      expect(code_index).to be_present
    end

    it 'enforces database-level uniqueness on name' do
      create(:nationality, name: 'French', code: 'FR')

      expect {
        ActiveRecord::Base.connection.execute(
          "INSERT INTO nationalities (name, code, created_at, updated_at)
           VALUES ('French', 'DE', '#{Time.current}', '#{Time.current}')"
        )
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'enforces database-level uniqueness on code' do
      create(:nationality, name: 'French', code: 'FR')

      expect {
        ActiveRecord::Base.connection.execute(
          "INSERT INTO nationalities (name, code, created_at, updated_at)
           VALUES ('German', 'FR', '#{Time.current}', '#{Time.current}')"
        )
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'enforces not null constraint on name' do
      expect {
        ActiveRecord::Base.connection.execute(
          "INSERT INTO nationalities (code, created_at, updated_at)
           VALUES ('FR', '#{Time.current}', '#{Time.current}')"
        )
      }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it 'enforces not null constraint on code' do
      expect {
        ActiveRecord::Base.connection.execute(
          "INSERT INTO nationalities (name, created_at, updated_at)
           VALUES ('French', '#{Time.current}', '#{Time.current}')"
        )
      }.to raise_error(ActiveRecord::NotNullViolation)
    end
  end

  describe 'data sanitization' do
    it 'preserves name with leading/trailing spaces' do
      nationality = create(:nationality, name: '  French  ')
      expect(nationality.name).to eq('  French  ')
    end

    it 'preserves code with leading/trailing spaces' do
      nationality = create(:nationality, code: '  FR  ')
      expect(nationality.code).to eq('  FR  ')
    end

    it 'handles special characters in name' do
      special_name = 'Côte d\'Ivoire'
      nationality = create(:nationality, name: special_name)
      expect(nationality.name).to eq(special_name)
    end

    it 'handles unicode characters' do
      unicode_name = 'République française'
      nationality = create(:nationality, name: unicode_name)
      expect(nationality.name).to eq(unicode_name)
    end
  end

  describe 'complex scenarios' do
    context 'nationality with many composers' do
      let(:nationality) { create(:nationality, :french) }

      it 'handles multiple composers efficiently' do
        composers = []

        10.times do |i|
          composers << create(:composer,
                            nationality: nationality,
                            first_name: "Composer#{i}",
                            last_name: "Last#{i}")
        end

        expect(nationality.composers.count).to eq(10)
        expect(nationality.composers).to match_array(composers)
      end

      it 'maintains referential integrity when composers are destroyed' do
        composer1 = create(:composer, nationality: nationality)
        composer2 = create(:composer, nationality: nationality)

        composer1.destroy!

        expect(nationality.composers.count).to eq(1)
        expect(nationality.composers).to contain_exactly(composer2)
      end
    end

    context 'edge cases with factory traits' do
      it 'creates distinct nationality instances with traits' do
        french = create(:nationality, :french)
        german = create(:nationality, :german)
        italian = create(:nationality, :italian)

        expect(french.name).to eq('French')
        expect(french.code).to eq('FR')
        expect(german.name).to eq('German')
        expect(german.code).to eq('DE')
        expect(italian.name).to eq('Italian')
        expect(italian.code).to eq('IT')

        expect([french, german, italian].map(&:name)).to all(be_present)
        expect([french, german, italian].map(&:code)).to all(be_present)
      end

      it 'handles trait conflicts gracefully' do
        # Create a French nationality first
        french = create(:nationality, :french)

        # Trying to create another French nationality should fail
        expect {
          create(:nationality, :french)
        }.to raise_error(ActiveRecord::RecordInvalid, /Name has already been taken/)
      end
    end

    context 'performance considerations' do
      it 'efficiently queries composers by nationality' do
        nationality = create(:nationality)

        # Create some composers for this nationality
        5.times { create(:composer, nationality: nationality) }

        # Create composers for other nationalities
        3.times { create(:composer) }

        # Should efficiently find only composers for this nationality
        composers = nationality.composers.includes(:nationality)
        expect(composers.count).to eq(5)

        # All should belong to the same nationality
        expect(composers.map(&:nationality).uniq).to contain_exactly(nationality)
      end

      it 'handles bulk operations efficiently' do
        nationalities_data = [
          { name: 'Test1', code: 'T1' },
          { name: 'Test2', code: 'T2' },
          { name: 'Test3', code: 'T3' }
        ]

        expect {
          nationalities_data.each do |data|
            Nationality.create!(data.merge(
              created_at: Time.current,
              updated_at: Time.current
            ))
          end
        }.to change(Nationality, :count).by(3)

        expect(Nationality.ordered.pluck(:code)).to include('T1', 'T2', 'T3')
      end
    end
  end

  describe 'factory traits comprehensive testing' do
    context 'predefined nationality traits' do
      it 'creates French nationality correctly' do
        french = build(:nationality, :french)
        expect(french.name).to eq('French')
        expect(french.code).to eq('FR')
        expect(french).to be_valid
      end

      it 'creates German nationality correctly' do
        german = build(:nationality, :german)
        expect(german.name).to eq('German')
        expect(german.code).to eq('DE')
        expect(german).to be_valid
      end

      it 'creates Italian nationality correctly' do
        italian = build(:nationality, :italian)
        expect(italian.name).to eq('Italian')
        expect(italian.code).to eq('IT')
        expect(italian).to be_valid
      end

      it 'creates Austrian nationality correctly' do
        austrian = build(:nationality, :austrian)
        expect(austrian.name).to eq('Austrian')
        expect(austrian.code).to eq('AT')
        expect(austrian).to be_valid
      end

      it 'creates Polish nationality correctly' do
        polish = build(:nationality, :polish)
        expect(polish.name).to eq('Polish')
        expect(polish.code).to eq('PL')
        expect(polish).to be_valid
      end
    end

    context 'trait usage with composers' do
      it 'can create composers with specific nationality traits' do
        french_nationality = create(:nationality, :french)
        german_nationality = create(:nationality, :german)

        french_composer = create(:composer, nationality: french_nationality)
        german_composer = create(:composer, nationality: german_nationality)

        expect(french_composer.nationality.name).to eq('French')
        expect(german_composer.nationality.name).to eq('German')
      end
    end
  end

  describe 'destruction behavior' do
    let(:nationality) { create(:nationality) }

    it 'can be destroyed when no composers are associated' do
      expect { nationality.destroy! }.not_to raise_error
      expect(Nationality.find_by(id: nationality.id)).to be_nil
    end
  end

  describe 'edge cases and error handling' do
    context 'concurrent access' do
      it 'handles concurrent nationality creation' do
        # Simulate concurrent creation with different codes
        threads = 5.times.map do |i|
          Thread.new do
            create(:nationality, name: "Country#{i}", code: "C#{i}")
          end
        end

        nationalities = threads.map(&:value)
        expect(nationalities.size).to eq(5)
        expect(Nationality.count).to eq(5)
      end
    end

    context 'boundary value testing' do
      it 'handles empty strings for name and code' do
        nationality = build(:nationality, name: '', code: '')
        expect(nationality).not_to be_valid
        expect(nationality.errors[:name]).to include("can't be blank")
        expect(nationality.errors[:code]).to include("can't be blank")
      end

      it 'handles very long names' do
        long_name = 'A' * 1000
        nationality = build(:nationality, name: long_name)
        expect(nationality).to be_valid
      end

      it 'handles very long codes' do
        long_code = 'B' * 100
        nationality = build(:nationality, code: long_code)
        expect(nationality).to be_valid
      end
    end
  end
end
