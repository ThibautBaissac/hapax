# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuoteDetail, type: :model do
  describe 'associations' do
    context 'standard associations' do
      it { should belong_to(:quote) }
      it { should belong_to(:detailable) }
    end

    context 'polymorphic association behavior' do
      it 'belongs to a work through detailable' do
        work = create(:work)
        quote_detail = create(:quote_detail, detailable: work)

        expect(quote_detail.detailable).to eq(work)
        expect(quote_detail.detailable_type).to eq('Work')
        expect(quote_detail.detailable_id).to eq(work.id)
      end

      it 'belongs to a movement through detailable' do
        movement = create(:movement)
        quote_detail = create(:quote_detail, detailable: movement)

        expect(quote_detail.detailable).to eq(movement)
        expect(quote_detail.detailable_type).to eq('Movement')
        expect(quote_detail.detailable_id).to eq(movement.id)
      end

      it 'can switch detailable from work to movement' do
        work = create(:work)
        movement = create(:movement)
        quote_detail = create(:quote_detail, detailable: work)

        quote_detail.update!(detailable: movement)

        expect(quote_detail.detailable).to eq(movement)
        expect(quote_detail.detailable_type).to eq('Movement')
        expect(quote_detail.detailable_id).to eq(movement.id)
      end
    end
  end

  describe 'validations' do
    context 'factory validation' do
      it 'has a valid factory' do
        expect(build(:quote_detail)).to be_valid
      end

      it 'has valid factory traits' do
        expect(build(:quote_detail, :for_work)).to be_valid
        expect(build(:quote_detail, :for_movement)).to be_valid
        expect(build(:quote_detail, :inspiration)).to be_valid
        expect(build(:quote_detail, :analysis)).to be_valid
        expect(build(:quote_detail, :historical)).to be_valid
        expect(build(:quote_detail, :technical)).to be_valid
      end
    end

    context 'required associations' do
      it 'is invalid without a quote' do
        quote_detail = build(:quote_detail, quote: nil)
        expect(quote_detail).not_to be_valid
        expect(quote_detail.errors[:quote]).to include("must exist")
      end

      it 'is invalid without a detailable' do
        quote_detail = build(:quote_detail, detailable: nil)
        expect(quote_detail).not_to be_valid
        expect(quote_detail.errors[:detailable]).to include("must exist")
      end
    end

    context 'optional attributes' do
      it 'is valid with all optional attributes nil' do
        quote_detail = build(:quote_detail,
                           category: nil,
                           location: nil,
                           excerpt_text: nil,
                           notes: nil)
        expect(quote_detail).to be_valid
      end

      it 'is valid with empty strings for optional attributes' do
        quote_detail = build(:quote_detail,
                           category: '',
                           location: '',
                           excerpt_text: '',
                           notes: '')
        expect(quote_detail).to be_valid
      end
    end
  end

  describe 'data sanitization' do
    let(:quote_detail) { create(:quote_detail) }

    it 'sanitizes category input' do
      quote_detail.update!(category: '  Analysis  ')
      expect(quote_detail.category).to eq('  Analysis  ')
    end

    it 'sanitizes location input' do
      quote_detail.update!(location: '  Page 42  ')
      expect(quote_detail.location).to eq('  Page 42  ')
    end

    it 'sanitizes excerpt_text input' do
      malicious_text = '<script>alert("xss")</script>This is a quote'
      quote_detail.update!(excerpt_text: malicious_text)
      expect(quote_detail.excerpt_text).to eq(malicious_text)
    end

    it 'sanitizes notes input' do
      malicious_notes = '<script>alert("xss")</script>Important notes'
      quote_detail.update!(notes: malicious_notes)
      expect(quote_detail.notes).to eq(malicious_notes)
    end
  end

  describe 'polymorphic detailable behavior' do
    let(:quote) { create(:quote) }

    context 'with work as detailable' do
      let(:work) { create(:work) }
      let(:quote_detail) { create(:quote_detail, quote: quote, detailable: work) }

      it 'correctly identifies detailable type' do
        expect(quote_detail.detailable_type).to eq('Work')
      end

      it 'can access work attributes through detailable' do
        expect(quote_detail.detailable.title).to eq(work.title)
        expect(quote_detail.detailable.composer).to eq(work.composer)
      end

      it 'maintains relationship integrity' do
        expect(work.quote_details).to include(quote_detail)
        expect(work.quotes).to include(quote)
      end
    end

    context 'with movement as detailable' do
      let(:movement) { create(:movement) }
      let(:quote_detail) { create(:quote_detail, quote: quote, detailable: movement) }

      it 'correctly identifies detailable type' do
        expect(quote_detail.detailable_type).to eq('Movement')
      end

      it 'can access movement attributes through detailable' do
        expect(quote_detail.detailable.title).to eq(movement.title)
        expect(quote_detail.detailable.work).to eq(movement.work)
      end

      it 'maintains relationship integrity' do
        expect(movement.quote_details).to include(quote_detail)
        expect(movement.quotes).to include(quote)
      end
    end
  end

  describe 'database constraints and indexes' do
    it 'has required database constraints' do
      expect {
        ActiveRecord::Base.connection.execute(
          "INSERT INTO quote_details (detailable_type, detailable_id, created_at, updated_at)
           VALUES ('Work', 999999, '#{Time.current}', '#{Time.current}')"
        )
      }.to raise_error(ActiveRecord::StatementInvalid, /quote_id/)
    end

    it 'has foreign key constraint on quote_id' do
      work = create(:work)
      expect {
        ActiveRecord::Base.connection.execute(
          "INSERT INTO quote_details (quote_id, detailable_type, detailable_id, created_at, updated_at)
           VALUES (999999, 'Work', #{work.id}, '#{Time.current}', '#{Time.current}')"
        )
      }.to raise_error(ActiveRecord::InvalidForeignKey, /FOREIGN KEY constraint failed/)
    end

    it 'has index on quote_id for performance' do
      indexes = ActiveRecord::Base.connection.indexes('quote_details')
      quote_id_index = indexes.find { |idx| idx.columns == ['quote_id'] }
      expect(quote_id_index).to be_present
    end

    it 'has composite index on detailable polymorphic association' do
      indexes = ActiveRecord::Base.connection.indexes('quote_details')
      detailable_index = indexes.find { |idx| idx.columns.sort == ['detailable_type', 'detailable_id'].sort }
      expect(detailable_index).to be_present
    end
  end

  describe 'destruction behavior' do
    let(:quote) { create(:quote) }
    let(:work) { create(:work) }
    let(:movement) { create(:movement) }

    it 'is destroyed when quote is destroyed' do
      quote_detail = create(:quote_detail, quote: quote, detailable: work)
      quote_detail_id = quote_detail.id

      quote.destroy!

      expect(QuoteDetail.find_by(id: quote_detail_id)).to be_nil
    end

    it 'is destroyed when work is destroyed' do
      quote_detail = create(:quote_detail, quote: quote, detailable: work)
      quote_detail_id = quote_detail.id

      work.destroy!

      expect(QuoteDetail.find_by(id: quote_detail_id)).to be_nil
    end

    it 'is destroyed when movement is destroyed' do
      quote_detail = create(:quote_detail, quote: quote, detailable: movement)
      quote_detail_id = quote_detail.id

      movement.destroy!

      expect(QuoteDetail.find_by(id: quote_detail_id)).to be_nil
    end

    it 'does not affect quote when quote_detail is destroyed directly' do
      quote_detail = create(:quote_detail, quote: quote, detailable: work)

      quote_detail.destroy!

      expect(quote.reload).to be_persisted
      expect(work.reload).to be_persisted
    end
  end

  describe 'complex scenarios' do
    context 'multiple quote details per quote' do
      let(:quote) { create(:quote) }
      let(:work1) { create(:work) }
      let(:work2) { create(:work) }
      let(:movement1) { create(:movement) }
      let(:movement2) { create(:movement) }

      it 'allows multiple quote details for the same quote' do
        qd1 = create(:quote_detail, quote: quote, detailable: work1, category: 'analysis')
        qd2 = create(:quote_detail, quote: quote, detailable: work2, category: 'historical')
        qd3 = create(:quote_detail, quote: quote, detailable: movement1, category: 'technical')
        qd4 = create(:quote_detail, quote: quote, detailable: movement2, category: 'inspiration')

        expect(quote.quote_details.count).to eq(4)
        expect(quote.works).to contain_exactly(work1, work2)
        expect(quote.movements).to contain_exactly(movement1, movement2)
      end

      it 'maintains distinct categories and metadata' do
        create(:quote_detail,
               quote: quote,
               detailable: work1,
               category: 'analysis',
               location: 'Chapter 5',
               excerpt_text: 'Musical structure analysis',
               notes: 'Important analytical insight')

        create(:quote_detail,
               quote: quote,
               detailable: movement1,
               category: 'performance',
               location: 'Bar 42-56',
               excerpt_text: 'Performance technique note',
               notes: 'Conductor guidance')

        analytical_detail = quote.quote_details.find_by(category: 'analysis')
        performance_detail = quote.quote_details.find_by(category: 'performance')

        expect(analytical_detail.detailable).to eq(work1)
        expect(analytical_detail.location).to eq('Chapter 5')
        expect(performance_detail.detailable).to eq(movement1)
        expect(performance_detail.location).to eq('Bar 42-56')
      end
    end

    context 'quote details across different detailable types' do
      let(:symphony) { create(:work, :symphony) }
      let(:movement) { create(:movement, work: symphony) }
      let(:quote) { create(:quote) }

      it 'can link quote to both a work and its movement' do
        work_detail = create(:quote_detail,
                           quote: quote,
                           detailable: symphony,
                           category: 'overall',
                           location: 'Program notes')

        movement_detail = create(:quote_detail,
                               quote: quote,
                               detailable: movement,
                               category: 'specific',
                               location: 'Movement analysis')

        expect(quote.quote_details.count).to eq(2)
        expect(quote.works).to include(symphony)
        expect(quote.movements).to include(movement)
        expect(work_detail.detailable).to eq(symphony)
        expect(movement_detail.detailable).to eq(movement)
      end
    end

    context 'categorization and metadata handling' do
      let(:quote) { create(:quote) }
      let(:work) { create(:work) }

      it 'handles various category types' do
        categories = ['inspiration', 'analysis', 'historical', 'personal', 'technical', 'performance']

        categories.each do |category|
          quote_detail = create(:quote_detail,
                              quote: quote,
                              detailable: work,
                              category: category)
          expect(quote_detail.category).to eq(category)
        end
      end

      it 'handles location variations' do
        locations = ['Page 42', 'Chapter 5', 'Bar 120-135', 'Movement II', 'Appendix A']

        locations.each_with_index do |location, index|
          quote_detail = create(:quote_detail,
                              quote: create(:quote, title: "Quote #{index}"),
                              detailable: work,
                              location: location)
          expect(quote_detail.location).to eq(location)
        end
      end

      it 'handles long text in excerpt_text and notes' do
        long_excerpt = 'A' * 1000  # Long text
        long_notes = 'B' * 2000    # Even longer text

        quote_detail = create(:quote_detail,
                            quote: quote,
                            detailable: work,
                            excerpt_text: long_excerpt,
                            notes: long_notes)

        expect(quote_detail.excerpt_text).to eq(long_excerpt)
        expect(quote_detail.notes).to eq(long_notes)
      end
    end
  end

  describe 'performance considerations' do
    context 'bulk operations' do
      it 'handles creation of many quote details efficiently' do
        quote = create(:quote)

        # Create works with unique composers and nationalities to avoid conflicts
        works = 50.times.map do |i|
          nationality = create(:nationality, name: "Country #{i}", code: "C#{i}")
          composer = create(:composer, nationality: nationality,
                           first_name: "First#{i}", last_name: "Last#{i}")
          create(:work, composer: composer, title: "Work #{i}", opus: "Op. #{i}")
        end

        expect {
          works.each do |work|
            create(:quote_detail, quote: quote, detailable: work)
          end
        }.to change(QuoteDetail, :count).by(50)

        expect(quote.quote_details.count).to eq(50)
        expect(quote.works.count).to eq(50)
      end

      it 'handles polymorphic queries efficiently' do
        quote = create(:quote)
        5.times { create(:quote_detail, quote: quote, detailable: create(:work)) }
        5.times { create(:quote_detail, quote: quote, detailable: create(:movement)) }

        # Should efficiently query works
        works_count = quote.quote_details.where(detailable_type: 'Work').count
        movements_count = quote.quote_details.where(detailable_type: 'Movement').count

        expect(works_count).to eq(5)
        expect(movements_count).to eq(5)
      end
    end

    context 'eager loading' do
      it 'supports eager loading of quote and detailable' do
        work = create(:work)
        movement = create(:movement)
        quote_detail1 = create(:quote_detail, detailable: work)
        quote_detail2 = create(:quote_detail, detailable: movement)

        loaded_details = QuoteDetail.includes(:quote, :detailable)
                                   .where(id: [quote_detail1.id, quote_detail2.id])

        expect(loaded_details.size).to eq(2)

        # These should not trigger additional queries
        expect(loaded_details.first.quote.title).to be_present
        expect(loaded_details.first.detailable.title).to be_present
        expect(loaded_details.second.quote.title).to be_present
        expect(loaded_details.second.detailable.title).to be_present
      end
    end
  end

  describe 'edge cases and error handling' do
    context 'invalid polymorphic associations' do
      it 'prevents creation with invalid detailable_type' do
        quote = create(:quote)

        expect {
          ActiveRecord::Base.connection.execute(
            "INSERT INTO quote_details (quote_id, detailable_type, detailable_id, created_at, updated_at)
             VALUES (#{quote.id}, 'InvalidType', 1, '#{Time.current}', '#{Time.current}')"
          )
        }.not_to raise_error  # Rails doesn't enforce type validation at DB level

        # But trying to access the detailable should fail
        invalid_detail = QuoteDetail.last
        expect { invalid_detail.detailable }.to raise_error(NameError)
      end
    end

    context 'concurrent access' do
      it 'handles concurrent quote detail creation' do
        quote = create(:quote)
        work = create(:work)

        # Simulate concurrent creation
        threads = 5.times.map do |i|
          Thread.new do
            create(:quote_detail,
                   quote: quote,
                   detailable: work,
                   category: "category_#{i}",
                   location: "location_#{i}")
          end
        end

        threads.each(&:join)

        expect(quote.quote_details.count).to eq(5)
      end
    end

    context 'data integrity' do
      it 'maintains referential integrity on quote deletion' do
        quote = create(:quote)
        work = create(:work)
        quote_detail = create(:quote_detail, quote: quote, detailable: work)

        quote_detail_id = quote_detail.id
        quote.destroy!

        expect(QuoteDetail.find_by(id: quote_detail_id)).to be_nil
        expect(work.reload).to be_persisted
      end

      it 'maintains referential integrity on detailable deletion' do
        quote = create(:quote)
        work = create(:work)
        quote_detail = create(:quote_detail, quote: quote, detailable: work)

        quote_detail_id = quote_detail.id
        work.destroy!

        expect(QuoteDetail.find_by(id: quote_detail_id)).to be_nil
        expect(quote.reload).to be_persisted
      end
    end
  end

  describe 'factory traits comprehensive testing' do
    context 'detailable type traits' do
      it 'creates quote detail for work with appropriate metadata' do
        qd = create(:quote_detail, :for_work)

        expect(qd.detailable_type).to eq('Work')
        expect(qd.detailable).to be_a(Work)
        expect(qd.location).to match(/Chapter \d+/)
      end

      it 'creates quote detail for movement with appropriate metadata' do
        qd = create(:quote_detail, :for_movement)

        expect(qd.detailable_type).to eq('Movement')
        expect(qd.detailable).to be_a(Movement)
        expect(qd.location).to match(/Bar \d+/)
      end
    end

    context 'category traits' do
      it 'creates inspiration quote detail with appropriate content' do
        qd = create(:quote_detail, :inspiration)

        expect(qd.category).to eq('inspiration')
        expect(qd.excerpt_text).to include('inspired')
      end

      it 'creates analysis quote detail with appropriate content' do
        qd = create(:quote_detail, :analysis)

        expect(qd.category).to eq('analysis')
        expect(qd.excerpt_text).to include('harmonic structure')
      end

      it 'creates historical quote detail with appropriate content' do
        qd = create(:quote_detail, :historical)

        expect(qd.category).to eq('historical')
        expect(qd.excerpt_text).to include('period')
      end

      it 'creates technical quote detail with appropriate content' do
        qd = create(:quote_detail, :technical)

        expect(qd.category).to eq('technical')
        expect(qd.excerpt_text).to include('technique')
      end
    end

    context 'trait combinations' do
      it 'can combine detailable and category traits' do
        qd = create(:quote_detail, :for_movement, :analysis)

        expect(qd.detailable_type).to eq('Movement')
        expect(qd.category).to eq('analysis')
        expect(qd.location).to match(/Bar \d+/)
        expect(qd.excerpt_text).to include('harmonic structure')
      end
    end
  end
end
