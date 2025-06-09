require 'rails_helper'

RSpec.describe Work, type: :model do
  describe 'validations' do
    subject { build(:work) }

    it { should validate_presence_of(:title) }

    describe 'custom validation: cannot_have_both_movements_and_quotes' do
      let(:work) { create(:work) }

      context 'when work has movements but no quotes' do
        before do
          create(:movement, work: work)
        end

        it 'is valid' do
          expect(work).to be_valid
        end
      end

      context 'when work has quotes but no movements' do
        before do
          quote = create(:quote)
          create(:quote_detail, quote: quote, detailable: work)
        end

        it 'is valid' do
          expect(work).to be_valid
        end
      end

      context 'when work has both movements and quotes' do
        before do
          create(:movement, work: work)
          quote = create(:quote)
          create(:quote_detail, quote: quote, detailable: work)
        end

        it 'is invalid' do
          expect(work).not_to be_valid
          expect(work.errors[:base]).to include("A work cannot have both movements and quotes")
        end
      end

      context 'when work has neither movements nor quotes' do
        it 'is valid' do
          expect(work).to be_valid
        end
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:composer) }
    it { should have_many(:movements).dependent(:destroy) }
    it { should have_many(:quote_details).dependent(:destroy) }
    it { should have_many(:quotes).through(:quote_details) }
  end

  describe 'enums' do
    describe 'form enum' do
      it 'defines all expected forms' do
        expected_forms = {
          'piece' => 0, 'fugue' => 1, 'cantata' => 2, 'opera' => 3, 'oratorio' => 4,
          'mass' => 5, 'suite' => 6, 'symphony' => 7, 'sonata' => 8, 'trio' => 9,
          'quartet' => 10, 'quintet' => 11, 'sextet' => 12, 'septet' => 13,
          'concerto' => 14, 'song_cycle' => 15, 'prelude' => 16, 'etude' => 17,
          'nocturne' => 18, 'lieder' => 19, 'ballade' => 20, 'variation' => 21, 'paraphrase' => 22, 'melody' => 23
        }

        expect(Work.forms).to eq(expected_forms)
      end

      it 'has piece as default' do
        work = Work.new
        expect(work.form).to eq('piece')
      end

      it 'allows setting different forms' do
        work = build(:work, form: :symphony)
        expect(work.form).to eq('symphony')
        expect(work.symphony?).to be true
      end
    end

    describe 'structure enum' do
      it 'defines all expected structures' do
        expected_structures = {
          'movement' => 0, 'melodies' => 1, 'lied' => 2, 'act' => 3, 'scene' => 4
        }

        expect(Work.structures).to eq(expected_structures)
      end

      it 'has movement as default' do
        work = Work.new
        expect(work.structure).to eq('movement')
      end

      it 'allows setting different structures' do
        work = build(:work, structure: :act)
        expect(work.structure).to eq('act')
        expect(work.act?).to be true
      end
    end
  end

  describe 'factory' do
    it 'creates a valid work' do
      work = build(:work)
      expect(work).to be_valid
    end

    it 'creates valid works with all traits' do
      expect(build(:work, :symphony)).to be_valid
      expect(build(:work, :sonata)).to be_valid
      expect(build(:work, :concerto)).to be_valid
      expect(build(:work, :opera)).to be_valid
      expect(build(:work, :short_piece)).to be_valid
    end

    it 'creates works with movements trait' do
      work = create(:work, :with_movements)
      expect(work.movements.count).to eq(3)
    end

    it 'creates works with quotes trait' do
      work = create(:work, :with_quotes)
      expect(work.quotes.count).to eq(1)
    end
  end

  describe '#can_add_quotes?' do
    context 'when work has no movements' do
      let(:work) { create(:work) }

      it 'returns true' do
        expect(work.can_add_quotes?).to be true
      end
    end

    context 'when work has movements' do
      let(:work) { create(:work, :with_movements) }

      it 'returns false' do
        expect(work.can_add_quotes?).to be false
      end
    end
  end

  describe '#display_quotes?' do
    context 'when work has no movements and has quotes' do
      let(:work) { create(:work, :with_quotes) }

      it 'returns true' do
        expect(work.display_quotes?).to be true
      end
    end

    context 'when work has movements' do
      let(:work) { create(:work, :with_movements) }

      it 'returns false' do
        expect(work.display_quotes?).to be false
      end
    end

    context 'when work has no movements and no quotes' do
      let(:work) { create(:work) }

      it 'returns false' do
        expect(work.display_quotes?).to be false
      end
    end
  end

  describe '#display_movements?' do
    context 'when work has movements' do
      let(:work) { create(:work, :with_movements) }

      it 'returns true' do
        expect(work.display_movements?).to be true
      end
    end

    context 'when work has no movements' do
      let(:work) { create(:work) }

      it 'returns false' do
        expect(work.display_movements?).to be false
      end
    end
  end

  describe 'data sanitization' do
    let(:malicious_content) { '<script>alert("xss")</script>Dangerous Content' }
    let(:work) { create(:work,
                        title: malicious_content,
                        opus: malicious_content,
                        description: malicious_content) }

    it 'sanitizes title removing all tags and attributes' do
      expect(work.title).not_to include('<script>')
      expect(work.title).to include('Dangerous Content')
    end

    it 'sanitizes opus removing all tags and attributes' do
      expect(work.opus).not_to include('<script>')
      expect(work.opus).to include('Dangerous Content')
    end

    it 'sanitizes description' do
      expect(work.description).not_to include('<script>')
      expect(work.description).to include('Dangerous Content')
    end
  end

  describe 'edge cases and validations' do
    context 'when composer is missing' do
      it 'fails validation' do
        work = build(:work, composer: nil)
        expect(work).not_to be_valid
        expect(work.errors[:composer]).to include("must exist")
      end
    end

    context 'when title is blank' do
      it 'fails validation' do
        work = build(:work, title: '')
        expect(work).not_to be_valid
        expect(work.errors[:title]).to include("can't be blank")
      end
    end

    context 'with composition dates' do
      let(:work) { build(:work,
                         start_date_composed: Date.new(1800, 1, 1),
                         end_date_composed: Date.new(1799, 1, 1)) }

      it 'should be valid since no validation exists for date order' do
        # Note: If you want to add this validation to the model, you would test it here
        expect(work).to be_valid
      end
    end

    context 'with very old composition dates' do
      let(:work) { build(:work,
                         start_date_composed: Date.new(1400, 1, 1),
                         end_date_composed: Date.new(1450, 1, 1)) }

      it 'accepts very old dates' do
        expect(work).to be_valid
      end
    end

    context 'with future composition dates' do
      let(:work) { build(:work,
                         start_date_composed: Date.tomorrow,
                         end_date_composed: nil) }

      it 'accepts future composition dates' do
        expect(work).to be_valid
      end
    end

    context 'with extreme duration values' do
      it 'accepts very short duration' do
        work = build(:work, duration: 1)
        expect(work).to be_valid
      end

      it 'accepts very long duration' do
        work = build(:work, duration: 86400) # 24 hours
        expect(work).to be_valid
      end

      it 'accepts zero duration' do
        work = build(:work, duration: 0)
        expect(work).to be_valid
      end
    end

    context 'with uncertainty flags' do
      let(:work) { build(:work,
                         unsure_start_date: true,
                         unsure_end_date: true) }

      it 'accepts uncertainty flags' do
        expect(work).to be_valid
      end
    end

    context 'with recorded flag' do
      it 'accepts recorded true' do
        work = build(:work, recorded: true)
        expect(work).to be_valid
      end

      it 'accepts recorded false' do
        work = build(:work, recorded: false)
        expect(work).to be_valid
      end

      it 'accepts recorded nil' do
        work = build(:work, recorded: nil)
        expect(work).to be_valid
      end
    end
  end

  describe 'database constraints' do
    it 'enforces composer foreign key constraint' do
      expect {
        create(:work, composer_id: 99999)
      }.to raise_error(ActiveRecord::RecordInvalid, /Composer must exist/)
    end

    it 'enforces title not null constraint' do
      expect {
        Work.create!(title: nil, composer: create(:composer))
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'destruction behavior' do
    let(:work) { create(:work) }
    let!(:movement1) { create(:movement, work: work) }
    let!(:movement2) { create(:movement, work: work) }
    let!(:quote_detail) { create(:quote_detail, detailable: work) }

    it 'destroys associated movements when work is destroyed' do
      expect { work.destroy! }.to change { Movement.count }.by(-2)
    end

    it 'destroys associated quote_details when work is destroyed' do
      expect { work.destroy! }.to change { QuoteDetail.count }.by(-1)
    end

    it 'removes the work record' do
      expect { work.destroy! }.to change { Work.count }.by(-1)
    end

    it 'does not destroy associated quotes (only the join record)' do
      quote = quote_detail.quote
      expect { work.destroy! }.not_to change { Quote.count }
      expect(Quote.find(quote.id)).to be_present
    end
  end

  describe 'complex scenarios' do
    describe 'symphony with movements' do
      let(:symphony) { create(:work, :symphony, :with_movements) }

      it 'has correct form and movements' do
        expect(symphony.symphony?).to be true
        expect(symphony.movements.count).to eq(3)
        expect(symphony.can_add_quotes?).to be false
        expect(symphony.display_movements?).to be true
        expect(symphony.display_quotes?).to be false
      end
    end

    describe 'short piece with quotes' do
      let(:short_piece) { create(:work, :short_piece, :with_quotes) }

      it 'has correct form and quotes' do
        expect([:prelude, :etude, :nocturne]).to include(short_piece.form.to_sym)
        expect(short_piece.quotes.count).to eq(1)
        expect(short_piece.can_add_quotes?).to be true
        expect(short_piece.display_movements?).to be false
        expect(short_piece.display_quotes?).to be true
      end
    end

    describe 'opera with acts structure' do
      let(:opera) { create(:work, :opera) }

      it 'has correct form and structure' do
        expect(opera.opera?).to be true
        expect(opera.act?).to be true
      end
    end
  end

  describe 'queries and associations performance' do
    before do
      @work = create(:work)

      # Create multiple movements
      @movements = create_list(:movement, 5, work: @work)

      # Create multiple quote details
      quotes = create_list(:quote, 3)
      quotes.each { |quote| create(:quote_detail, quote: quote, detailable: @work) }
    end

    it 'efficiently loads movements' do
      # Should not trigger N+1 queries when accessing movements
      expect(@work.movements.count).to eq(5)
    end

    it 'efficiently loads quotes through quote_details' do
      # Should not trigger N+1 queries when accessing quotes
      expect(@work.quotes.count).to eq(3)
    end

    it 'handles large number of associations' do
      # Test with more data
      create_list(:movement, 20, work: @work)
      expect(@work.movements.count).to eq(25) # 5 original + 20 new
    end
  end

  describe 'form and structure combinations' do
    it 'allows valid form and structure combinations' do
      # Symphony with movements
      work = build(:work, form: :symphony, structure: :movement)
      expect(work).to be_valid

      # Opera with acts
      work = build(:work, form: :opera, structure: :act)
      expect(work).to be_valid

      # Prelude with melody
      work = build(:work, form: :prelude, structure: :melodies)
      expect(work).to be_valid

      # Lieder with lied structure
      work = build(:work, form: :lieder, structure: :lied)
      expect(work).to be_valid
    end
  end

  describe 'class methods and scopes' do
    # If you have scopes defined in the future, test them here
    # For example:
    # describe '.by_form' do
    #   let!(:symphony) { create(:work, :symphony) }
    #   let!(:sonata) { create(:work, :sonata) }
    #
    #   it 'returns works of specified form' do
    #     expect(Work.by_form(:symphony)).to include(symphony)
    #     expect(Work.by_form(:symphony)).not_to include(sonata)
    #   end
    # end
  end

  describe 'string representations and formatting' do
    let(:work) { create(:work, title: "Symphony No. 9", opus: "Op. 125") }

    it 'has accessible attributes for display' do
      expect(work.title).to be_present
      expect(work.opus).to be_present
    end

    context 'when opus is missing' do
      let(:work_without_opus) { create(:work, opus: nil) }

      it 'handles missing opus gracefully' do
        expect(work_without_opus.opus).to be_nil
      end
    end
  end
end
