require 'rails_helper'

RSpec.describe Movement, type: :model do
  describe 'validations' do
    subject { build(:movement) }

    it { should validate_presence_of(:title) }
  end

  describe 'associations' do
    it { should belong_to(:work) }
    it { should have_many(:quote_details).dependent(:destroy) }
    it { should have_many(:quotes).through(:quote_details) }
  end

  describe 'factory' do
    it 'creates a valid movement' do
      movement = build(:movement)
      expect(movement).to be_valid
    end

    it 'creates valid movements with all traits' do
      expect(build(:movement, :first_movement)).to be_valid
      expect(build(:movement, :second_movement)).to be_valid
      expect(build(:movement, :third_movement)).to be_valid
      expect(build(:movement, :final_movement)).to be_valid
    end

    it 'creates movements with quotes trait' do
      movement = create(:movement, :with_quotes)
      expect(movement.quotes.count).to eq(1)
    end
  end

  describe 'data sanitization' do
    let(:malicious_content) { '<script>alert("xss")</script>Dangerous Content' }
    let(:movement) { create(:movement,
                            title: malicious_content,
                            description: malicious_content) }

    it 'sanitizes title removing all tags and attributes' do
      expect(movement.title).not_to include('<script>')
      expect(movement.title).to include('Dangerous Content')
    end

    it 'sanitizes description' do
      expect(movement.description).not_to include('<script>')
      expect(movement.description).to include('Dangerous Content')
    end
  end

  describe 'edge cases and validations' do
    context 'when work is missing' do
      it 'fails validation' do
        movement = build(:movement, work: nil)
        expect(movement).not_to be_valid
        expect(movement.errors[:work]).to include("must exist")
      end
    end

    context 'when title is blank' do
      it 'fails validation' do
        movement = build(:movement, title: '')
        expect(movement).not_to be_valid
        expect(movement.errors[:title]).to include("can't be blank")
      end
    end

    context 'with position values' do
      it 'accepts positive position values' do
        movement = build(:movement, position: 1)
        expect(movement).to be_valid
      end

      it 'accepts zero position' do
        movement = build(:movement, position: 0)
        expect(movement).to be_valid
      end

      it 'accepts large position values' do
        movement = build(:movement, position: 99)
        expect(movement).to be_valid
      end
    end

    context 'with duration values' do
      it 'accepts positive duration' do
        movement = build(:movement, duration: 300)
        expect(movement).to be_valid
      end

      it 'accepts zero duration' do
        movement = build(:movement, duration: 0)
        expect(movement).to be_valid
      end

      it 'accepts very long duration' do
        movement = build(:movement, duration: 7200) # 2 hours
        expect(movement).to be_valid
      end

      it 'accepts nil duration' do
        movement = build(:movement, duration: nil)
        expect(movement).to be_valid
      end
    end
  end

  describe 'database constraints' do
    it 'enforces work foreign key constraint' do
      expect {
        create(:movement, work_id: 99999)
      }.to raise_error(ActiveRecord::RecordInvalid, /Work must exist/)
    end

    it 'enforces title not null constraint' do
      expect {
        Movement.create!(title: nil, work: create(:work), position: 1)
      }.to raise_error(ActiveRecord::RecordInvalid, /Title can't be blank/)
    end

    it 'enforces position not null constraint' do
      expect {
        Movement.create!(title: "Test", work: create(:work), position: nil)
      }.to raise_error(ActiveRecord::NotNullViolation)
    end
  end

  describe 'destruction behavior' do
    let(:movement) { create(:movement) }
    let!(:quote_detail1) { create(:quote_detail, detailable: movement) }
    let!(:quote_detail2) { create(:quote_detail, detailable: movement) }

    it 'destroys associated quote_details when movement is destroyed' do
      expect { movement.destroy! }.to change { QuoteDetail.count }.by(-2)
    end

    it 'removes the movement record' do
      expect { movement.destroy! }.to change { Movement.count }.by(-1)
    end

    it 'does not destroy associated quotes (only the join records)' do
      quote1 = quote_detail1.quote
      quote2 = quote_detail2.quote
      expect { movement.destroy! }.not_to change { Quote.count }
      expect(Quote.find(quote1.id)).to be_present
      expect(Quote.find(quote2.id)).to be_present
    end
  end

  describe 'associations with quotes' do
    let(:movement) { create(:movement) }
    let(:quote1) { create(:quote) }
    let(:quote2) { create(:quote) }

    before do
      create(:quote_detail, quote: quote1, detailable: movement)
      create(:quote_detail, quote: quote2, detailable: movement)
    end

    it 'has many quotes through quote_details' do
      expect(movement.quotes).to include(quote1, quote2)
      expect(movement.quotes.count).to eq(2)
    end

    it 'can access quote details' do
      expect(movement.quote_details.count).to eq(2)
    end
  end

  describe 'movement ordering and positioning' do
    let(:work) { create(:work) }
    let!(:movement1) { create(:movement, work: work, position: 1, title: "I. Allegro") }
    let!(:movement2) { create(:movement, work: work, position: 2, title: "II. Andante") }
    let!(:movement3) { create(:movement, work: work, position: 3, title: "III. Menuetto") }
    let!(:movement4) { create(:movement, work: work, position: 4, title: "IV. Presto") }

    it 'can be ordered by position' do
      movements = work.movements.order(:position)
      expect(movements.first).to eq(movement1)
      expect(movements.last).to eq(movement4)
    end

    it 'maintains correct positions' do
      expect(movement1.position).to eq(1)
      expect(movement2.position).to eq(2)
      expect(movement3.position).to eq(3)
      expect(movement4.position).to eq(4)
    end

    it 'allows multiple movements with same position (if no unique constraint)' do
      # This tests that the model doesn't enforce unique positions at the Rails level
      duplicate_position_movement = build(:movement, work: work, position: 1)
      expect(duplicate_position_movement).to be_valid
    end
  end

  describe 'movement traits functionality' do
    describe 'first_movement trait' do
      let(:first_movement) { create(:movement, :first_movement) }

      it 'has correct attributes for first movement' do
        expect(first_movement.title).to eq("I. Allegro")
        expect(first_movement.position).to eq(1)
        expect(first_movement.duration).to be_between(600, 1200)
      end
    end

    describe 'second_movement trait' do
      let(:second_movement) { create(:movement, :second_movement) }

      it 'has correct attributes for second movement' do
        expect(second_movement.title).to eq("II. Andante")
        expect(second_movement.position).to eq(2)
        expect(second_movement.duration).to be_between(300, 900)
      end
    end

    describe 'third_movement trait' do
      let(:third_movement) { create(:movement, :third_movement) }

      it 'has correct attributes for third movement' do
        expect(third_movement.title).to eq("III. Menuetto")
        expect(third_movement.position).to eq(3)
        expect(third_movement.duration).to be_between(240, 480)
      end
    end

    describe 'final_movement trait' do
      let(:final_movement) { create(:movement, :final_movement) }

      it 'has correct attributes for final movement' do
        expect(final_movement.title).to eq("IV. Presto")
        expect(final_movement.position).to eq(4)
        expect(final_movement.duration).to be_between(360, 720)
      end
    end
  end

  describe 'complex scenarios' do
    describe 'symphony with multiple movements' do
      let(:symphony) { create(:work, :symphony) }
      let!(:movements) do
        [
          create(:movement, :first_movement, work: symphony),
          create(:movement, :second_movement, work: symphony),
          create(:movement, :third_movement, work: symphony),
          create(:movement, :final_movement, work: symphony)
        ]
      end

      it 'belongs to the same work' do
        movements.each do |movement|
          expect(movement.work).to eq(symphony)
        end
      end

      it 'has distinct positions' do
        positions = movements.map(&:position)
        expect(positions).to eq([1, 2, 3, 4])
      end

      it 'can be retrieved through work association' do
        expect(symphony.movements.count).to eq(4)
        expect(symphony.movements.order(:position)).to eq(movements)
      end
    end

    describe 'movement with multiple quotes' do
      let(:movement) { create(:movement, :with_quotes) }
      let(:additional_quote) { create(:quote) }

      before do
        create(:quote_detail, quote: additional_quote, detailable: movement)
      end

      it 'has multiple quotes' do
        expect(movement.quotes.count).to eq(2)
      end

      it 'maintains quote relationships' do
        expect(movement.quote_details.count).to eq(2)
      end
    end
  end

  describe 'performance and queries' do
    before do
      @work = create(:work)
      @movements = create_list(:movement, 10, work: @work)

      # Add quotes to some movements
      @movements.first(5).each do |movement|
        quotes = create_list(:quote, 2)
        quotes.each { |quote| create(:quote_detail, quote: quote, detailable: movement) }
      end
    end

    it 'efficiently loads movements for a work' do
      expect(@work.movements.count).to eq(10)
    end

    it 'efficiently loads quotes for movements' do
      movement_with_quotes = @movements.first
      expect(movement_with_quotes.quotes.count).to eq(2)
    end

    it 'handles large datasets efficiently' do
      # Create additional movements
      create_list(:movement, 50, work: @work)
      expect(@work.movements.count).to eq(60)
    end
  end

  describe 'string representations and display' do
    let(:movement) { create(:movement, title: "I. Allegro con spirito", description: "A lively opening movement") }

    it 'has accessible attributes for display' do
      expect(movement.title).to be_present
      expect(movement.description).to be_present
    end

    context 'when description is missing' do
      let(:movement_without_description) { create(:movement, description: nil) }

      it 'handles missing description gracefully' do
        expect(movement_without_description.description).to be_nil
      end
    end

    context 'with tempo markings in title' do
      let(:tempo_movement) { create(:movement, title: "II. Andante cantabile") }

      it 'preserves tempo markings in title' do
        expect(tempo_movement.title).to include("Andante")
      end
    end
  end

  describe 'edge cases with work association' do
    context 'when work is destroyed' do
      let(:work) { create(:work) }
      let(:movement) { create(:movement, work: work) }

      it 'is destroyed when work is destroyed (due to dependent: :destroy on work)' do
        movement_id = movement.id
        work.destroy!
        expect { Movement.find(movement_id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with work that cannot have movements' do
      # This tests the business rule that works with quotes cannot have movements
      let(:work_with_quotes) { create(:work, :with_quotes) }

      it 'can still be created at the model level but makes work invalid' do
        # The work starts valid (only has quotes, no movements)
        expect(work_with_quotes).to be_valid

        # The movement can be built (validation is on Work model, not Movement model)
        movement = build(:movement, work: work_with_quotes)
        expect(movement).to be_valid

        # But once the movement is created, the work becomes invalid
        movement.save!
        work_with_quotes.reload
        expect(work_with_quotes).not_to be_valid
        expect(work_with_quotes.errors[:base]).to include("A work cannot have both movements and quotes")
      end
    end
  end
end
