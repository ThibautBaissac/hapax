require 'rails_helper'

RSpec.describe Composer, type: :model do
  describe 'validations' do
    subject { build(:composer) }

    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end

  describe 'associations' do
    it { should belong_to(:nationality) }
    it { should have_many(:works).dependent(:destroy) }
    it { should have_one_attached(:portrait) }
  end

  describe 'factory' do
    it 'creates a valid composer' do
      composer = build(:composer)
      expect(composer).to be_valid
    end

    it 'creates a valid composer with all traits' do
      expect(build(:composer, :living)).to be_valid
      expect(build(:composer, :baroque)).to be_valid
      expect(build(:composer, :classical)).to be_valid
      expect(build(:composer, :romantic)).to be_valid
      expect(build(:composer, :bach)).to be_valid
      expect(build(:composer, :mozart)).to be_valid
      expect(build(:composer, :chopin)).to be_valid
    end
  end

  describe '#full_name' do
    context 'when both names are present' do
      let(:composer) { build(:composer, first_name: 'Johann Sebastian', last_name: 'Bach') }

      it 'returns the full name' do
        expect(composer.full_name).to eq('Johann Sebastian Bach')
      end
    end

    context 'when only first name is present' do
      let(:composer) { build(:composer, first_name: 'Johann', last_name: nil) }

      it 'returns only first name' do
        expect(composer.full_name).to eq('Johann')
      end
    end

    context 'when only last name is present' do
      let(:composer) { build(:composer, first_name: nil, last_name: 'Bach') }

      it 'returns only last name' do
        expect(composer.full_name).to eq('Bach')
      end
    end

    context 'when both names are blank' do
      let(:composer) { build(:composer, first_name: '', last_name: '') }

      it 'returns nil' do
        expect(composer.full_name).to be_nil
      end
    end
  end

  describe '#quotes' do
    let(:composer) { create(:composer) }
    let(:work_with_quotes) { create(:work, composer: composer) }
    let(:work_with_movements) { create(:work, composer: composer) }
    let(:movement1) { create(:movement, work: work_with_movements) }
    let(:movement2) { create(:movement, work: work_with_movements) }
    let(:quote1) { create(:quote) }
    let(:quote2) { create(:quote) }
    let(:quote3) { create(:quote) }

    before do
      # Create quote directly associated with work
      create(:quote_detail, quote: quote1, detailable: work_with_quotes)

      # Create quotes associated with movements
      create(:quote_detail, quote: quote2, detailable: movement1)
      create(:quote_detail, quote: quote3, detailable: movement2)
    end

    it 'returns quotes from composer works' do
      expect(composer.quotes).to include(quote1)
    end

    it 'returns quotes from composer work movements' do
      expect(composer.quotes).to include(quote2, quote3)
    end

    it 'returns all quotes related to composer' do
      expect(composer.quotes.count).to eq(3)
      expect(composer.quotes).to contain_exactly(quote1, quote2, quote3)
    end

    context 'when no quotes exist' do
      let(:composer_without_quotes) { create(:composer) }

      it 'returns empty relation' do
        expect(composer_without_quotes.quotes).to be_empty
      end
    end

    context 'when duplicate quotes exist across works and movements' do
      let(:shared_quote) { create(:quote) }

      before do
        # Associate same quote with both work and movement
        create(:quote_detail, quote: shared_quote, detailable: work_with_quotes)
        create(:quote_detail, quote: shared_quote, detailable: movement1)
      end

      it 'returns unique quotes only' do
        all_quotes = composer.quotes
        expect(all_quotes.where(id: shared_quote.id).count).to eq(1)
      end
    end
  end

  describe 'data sanitization' do
    let(:malicious_content) { '<script>alert("xss")</script>Dangerous Content' }
    let(:composer) { create(:composer,
                            first_name: malicious_content,
                            last_name: malicious_content,
                            short_bio: malicious_content,
                            bio: malicious_content) }

    it 'sanitizes first_name removing all tags and attributes' do
      expect(composer.first_name).not_to include('<script>')
      expect(composer.first_name).to include('Dangerous Content')
    end

    it 'sanitizes last_name removing all tags and attributes' do
      expect(composer.last_name).not_to include('<script>')
      expect(composer.last_name).to include('Dangerous Content')
    end

    it 'sanitizes short_bio' do
      expect(composer.short_bio).not_to include('<script>')
      expect(composer.short_bio).to include('Dangerous Content')
    end

    it 'sanitizes bio' do
      expect(composer.bio).not_to include('<script>')
      expect(composer.bio).to include('Dangerous Content')
    end
  end

  describe 'edge cases and validations' do
    context 'when nationality is missing' do
      it 'fails validation' do
        composer = build(:composer, nationality: nil)
        expect(composer).not_to be_valid
        expect(composer.errors[:nationality]).to include("must exist")
      end
    end

    context 'when first_name is blank' do
      it 'fails validation' do
        composer = build(:composer, first_name: '')
        expect(composer).not_to be_valid
        expect(composer.errors[:first_name]).to include("can't be blank")
      end
    end

    context 'when last_name is blank' do
      it 'fails validation' do
        composer = build(:composer, last_name: '')
        expect(composer).not_to be_valid
        expect(composer.errors[:last_name]).to include("can't be blank")
      end
    end

    context 'with death date before birth date' do
      let(:composer) { build(:composer, birth_date: Date.new(1900, 1, 1), death_date: Date.new(1850, 1, 1)) }

      it 'should be valid since no validation exists for this business rule' do
        # Note: If you want to add this validation to the model, you would test it here
        expect(composer).to be_valid
      end
    end

    context 'with very old dates' do
      let(:composer) { build(:composer, birth_date: Date.new(1400, 1, 1), death_date: Date.new(1450, 1, 1)) }

      it 'accepts very old dates' do
        expect(composer).to be_valid
      end
    end

    context 'with future dates' do
      let(:composer) { build(:composer, birth_date: Date.tomorrow, death_date: nil) }

      it 'accepts future birth dates for time travelers' do
        expect(composer).to be_valid
      end
    end
  end

  describe 'database constraints' do
    it 'enforces nationality foreign key constraint' do
      expect {
        create(:composer, nationality_id: 99999)
      }.to raise_error(ActiveRecord::RecordInvalid, /Nationality must exist/)
    end
  end

  describe 'destruction behavior' do
    let(:composer) { create(:composer) }
    let!(:work1) { create(:work, composer: composer) }
    let!(:work2) { create(:work, composer: composer) }

    it 'destroys associated works when composer is destroyed' do
      expect { composer.destroy! }.to change { Work.count }.by(-2)
    end

    it 'removes the composer record' do
      expect { composer.destroy! }.to change { Composer.count }.by(-1)
    end
  end

  describe 'portrait attachment' do
    let(:composer) { create(:composer) }

    context 'when portrait is attached' do
      before do
        composer.portrait.attach(
          io: StringIO.new("fake image content"),
          filename: "portrait.jpg",
          content_type: "image/jpeg"
        )
      end

      it 'has portrait attached' do
        expect(composer.portrait).to be_attached
      end
    end

    context 'when no portrait is attached' do
      it 'has no portrait attached' do
        expect(composer.portrait).not_to be_attached
      end
    end
  end

  describe 'complex queries with large datasets' do
    before do
      # Create a composer with many works and movements
      @composer = create(:composer)

      # Create works with quotes
      @works_with_quotes = create_list(:work, 5, composer: @composer)
      @works_with_quotes.each { |work| create(:quote_detail, detailable: work, quote: create(:quote)) }

      # Create works with movements that have quotes
      @works_with_movements = create_list(:work, 3, composer: @composer)
      @works_with_movements.each do |work|
        movements = create_list(:movement, 4, work: work)
        movements.each { |movement| create(:quote_detail, detailable: movement, quote: create(:quote)) }
      end
    end

    it 'efficiently retrieves all quotes' do
      # Should return 5 quotes from works + 12 quotes from movements (3 works * 4 movements)
      expect(@composer.quotes.count).to eq(17)
    end

    it 'returns correct count without duplicates' do
      # Verify that the quotes method handles complex queries correctly
      quotes = @composer.quotes
      expect(quotes.count).to eq(17)
      expect(quotes.pluck(:id).uniq.count).to eq(17) # No duplicates
    end
  end

  describe 'class methods and scopes' do
    # If you have scopes defined in the future, test them here
    # For example:
    # describe '.alive' do
    #   let!(:living_composer) { create(:composer, :living) }
    #   let!(:deceased_composer) { create(:composer, death_date: 1.year.ago) }
    #
    #   it 'returns only living composers' do
    #     expect(Composer.alive).to include(living_composer)
    #     expect(Composer.alive).not_to include(deceased_composer)
    #   end
    # end
  end
end
