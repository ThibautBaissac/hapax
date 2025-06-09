require 'rails_helper'

RSpec.describe Quote, type: :model do
  describe 'validations' do
    subject { build(:quote) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:author) }

    describe 'custom validation: acceptable_images' do
      let(:quote) { create(:quote) }

      context 'when no images are attached' do
        it 'is valid' do
          expect(quote).to be_valid
        end
      end

      context 'when valid images are attached' do
        let(:valid_image_content) { 'fake jpeg content' }

        before do
          allow_any_instance_of(ActiveStorage::Blob).to receive(:byte_size).and_return(1.megabyte)
          allow_any_instance_of(ActiveStorage::Blob).to receive(:content_type).and_return('image/jpeg')
        end

        it 'is valid' do
          quote.images.attach(
            io: StringIO.new(valid_image_content),
            filename: 'test.jpg',
            content_type: 'image/jpeg'
          )
          expect(quote).to be_valid
        end
      end

      context 'when image is too large' do
        let(:large_image_content) { 'fake large image content' }

        before do
          allow_any_instance_of(ActiveStorage::Blob).to receive(:byte_size).and_return(15.megabytes)
          allow_any_instance_of(ActiveStorage::Blob).to receive(:content_type).and_return('image/jpeg')
        end

        it 'is invalid' do
          quote.images.attach(
            io: StringIO.new(large_image_content),
            filename: 'large_image.jpg',
            content_type: 'image/jpeg'
          )
          expect(quote).not_to be_valid
          expect(quote.errors[:images]).to include('Image large_image.jpg is too large (maximum is 10MB)')
        end
      end

      context 'when image has invalid content type' do
        let(:invalid_image_content) { 'fake pdf content' }

        before do
          allow_any_instance_of(ActiveStorage::Blob).to receive(:byte_size).and_return(1.megabyte)
          allow_any_instance_of(ActiveStorage::Blob).to receive(:content_type).and_return('application/pdf')
        end

        it 'is invalid' do
          quote.images.attach(
            io: StringIO.new(invalid_image_content),
            filename: 'document.pdf',
            content_type: 'application/pdf'
          )
          expect(quote).not_to be_valid
          expect(quote.errors[:images]).to include('Image document.pdf must be a JPEG, PNG, or GIF')
        end
      end

      context 'with multiple images' do
        let(:valid_content) { 'fake image content' }
        let(:invalid_content) { 'fake large content' }

        before do
          # First image is valid
          allow_any_instance_of(ActiveStorage::Blob).to receive(:byte_size).and_return(1.megabyte)
          allow_any_instance_of(ActiveStorage::Blob).to receive(:content_type).and_return('image/png')

          quote.images.attach(
            io: StringIO.new(valid_content),
            filename: 'valid.png',
            content_type: 'image/png'
          )

          # Second image is too large
          allow_any_instance_of(ActiveStorage::Blob).to receive(:byte_size).and_return(15.megabytes)
          quote.images.attach(
            io: StringIO.new(invalid_content),
            filename: 'invalid.jpg',
            content_type: 'image/jpeg'
          )
        end

        it 'is invalid due to large image' do
          expect(quote).not_to be_valid
          expect(quote.errors[:images]).to include('Image invalid.jpg is too large (maximum is 10MB)')
        end
      end
    end
  end

  describe 'associations' do
    it { should have_many(:quote_details).dependent(:destroy) }
    it { should have_many(:works).through(:quote_details) }
    it { should have_many(:movements).through(:quote_details) }
    it { should have_many_attached(:images) }
  end

  describe 'factory' do
    it 'creates a valid quote' do
      quote = build(:quote)
      expect(quote).to be_valid
    end

    it 'creates valid quotes with all traits' do
      expect(build(:quote, :classical_music_quote)).to be_valid
      expect(build(:quote, :philosophy_quote)).to be_valid
      expect(build(:quote, :composer_quote)).to be_valid
    end

    it 'creates quotes with details for work' do
      quote = create(:quote, :with_details_for_work)
      expect(quote.works.count).to eq(1)
      expect(quote.quote_details.count).to eq(1)
    end

    it 'creates quotes with details for movement' do
      quote = create(:quote, :with_details_for_movement)
      expect(quote.movements.count).to eq(1)
      expect(quote.quote_details.count).to eq(1)
    end
  end

  describe '#title_with_author' do
    let(:quote) { build(:quote, title: 'The Meaning of Music', author: 'Leonard Bernstein') }

    it 'returns title with author in parentheses' do
      expect(quote.title_with_author).to eq('The Meaning of Music (by Leonard Bernstein)')
    end

    context 'with special characters in title and author' do
      let(:quote) { build(:quote, title: 'Music & Expression', author: 'John O\'Connor') }

      it 'handles special characters correctly' do
        expect(quote.title_with_author).to eq('Music & Expression (by John O\'Connor)')
      end
    end

    context 'with empty strings' do
      let(:quote) { build(:quote, title: '', author: '') }

      it 'handles empty strings' do
        expect(quote.title_with_author).to eq(' (by )')
      end
    end
  end

  describe 'data sanitization' do
    let(:malicious_content) { '<script>alert("xss")</script>Dangerous Content' }
    let(:quote) { create(:quote,
                         title: malicious_content,
                         author: malicious_content,
                         notes: malicious_content) }

    it 'sanitizes title removing all tags and attributes' do
      expect(quote.title).not_to include('<script>')
      expect(quote.title).to include('Dangerous Content')
    end

    it 'sanitizes author removing all tags and attributes' do
      expect(quote.author).not_to include('<script>')
      expect(quote.author).to include('Dangerous Content')
    end

    it 'sanitizes notes' do
      expect(quote.notes).not_to include('<script>')
      expect(quote.notes).to include('Dangerous Content')
    end
  end

  describe 'edge cases and validations' do
    context 'when title is blank' do
      it 'fails validation' do
        quote = build(:quote, title: '')
        expect(quote).not_to be_valid
        expect(quote.errors[:title]).to include("can't be blank")
      end
    end

    context 'when author is blank' do
      it 'fails validation' do
        quote = build(:quote, author: '')
        expect(quote).not_to be_valid
        expect(quote.errors[:author]).to include("can't be blank")
      end
    end

    context 'when notes is nil' do
      it 'is valid' do
        quote = build(:quote, notes: nil)
        expect(quote).to be_valid
      end
    end

    context 'when notes is empty string' do
      it 'is valid' do
        quote = build(:quote, notes: '')
        expect(quote).to be_valid
      end
    end

    context 'with very long title and author' do
      let(:long_text) { 'a' * 1000 }

      it 'accepts long title' do
        quote = build(:quote, title: long_text)
        expect(quote).to be_valid
      end

      it 'accepts long author' do
        quote = build(:quote, author: long_text)
        expect(quote).to be_valid
      end
    end

    context 'with unicode characters' do
      let(:quote) { build(:quote, title: 'Música y Expresión', author: 'José María') }

      it 'handles unicode characters' do
        expect(quote).to be_valid
        expect(quote.title).to include('ú')
        expect(quote.author).to include('é')
      end
    end
  end

  describe 'database constraints' do
    it 'enforces title not null constraint' do
      quote = Quote.new(title: nil, author: 'Test Author')
      quote.valid? # trigger validations to bypass them

      expect {
        # Use raw SQL to bypass Rails validations and test the database constraint
        ActiveRecord::Base.connection.execute(
          "INSERT INTO quotes (title, author, created_at, updated_at) VALUES (NULL, 'Test Author', datetime('now'), datetime('now'))"
        )
      }.to raise_error(ActiveRecord::StatementInvalid)
    end

    it 'enforces author not null constraint' do
      quote = Quote.new(title: 'Test Title', author: nil)
      quote.valid? # trigger validations to bypass them

      expect {
        # Use raw SQL to bypass Rails validations and test the database constraint
        ActiveRecord::Base.connection.execute(
          "INSERT INTO quotes (title, author, created_at, updated_at) VALUES ('Test Title', NULL, datetime('now'), datetime('now'))"
        )
      }.to raise_error(ActiveRecord::StatementInvalid)
    end
  end

  describe 'destruction behavior' do
    let(:quote) { create(:quote) }
    let(:work) { create(:work) }
    let(:movement) { create(:movement) }
    let!(:quote_detail1) { create(:quote_detail, quote: quote, detailable: work) }
    let!(:quote_detail2) { create(:quote_detail, quote: quote, detailable: movement) }

    it 'destroys associated quote_details when quote is destroyed' do
      expect { quote.destroy! }.to change { QuoteDetail.count }.by(-2)
    end

    it 'removes the quote record' do
      expect { quote.destroy! }.to change { Quote.count }.by(-1)
    end

    it 'does not destroy associated works or movements' do
      work_id = work.id
      movement_id = movement.id

      quote.destroy!

      expect(Work.find(work_id)).to be_present
      expect(Movement.find(movement_id)).to be_present
    end
  end

  describe 'associations with works and movements' do
    let(:quote) { create(:quote) }
    let(:work1) { create(:work) }
    let(:work2) { create(:work) }
    let(:movement1) { create(:movement) }
    let(:movement2) { create(:movement) }

    before do
      create(:quote_detail, quote: quote, detailable: work1)
      create(:quote_detail, quote: quote, detailable: work2)
      create(:quote_detail, quote: quote, detailable: movement1)
      create(:quote_detail, quote: quote, detailable: movement2)
    end

    it 'has many works through quote_details' do
      expect(quote.works).to include(work1, work2)
      expect(quote.works.count).to eq(2)
    end

    it 'has many movements through quote_details' do
      expect(quote.movements).to include(movement1, movement2)
      expect(quote.movements.count).to eq(2)
    end

    it 'can access all quote details' do
      expect(quote.quote_details.count).to eq(4)
    end

    it 'maintains correct source types' do
      work_details = quote.quote_details.where(detailable_type: 'Work')
      movement_details = quote.quote_details.where(detailable_type: 'Movement')

      expect(work_details.count).to eq(2)
      expect(movement_details.count).to eq(2)
    end
  end

  describe 'image attachments' do
    let(:quote) { create(:quote) }

    context 'when no images are attached' do
      it 'has no images attached' do
        expect(quote.images).not_to be_attached
      end
    end

    context 'when images are attached' do
      let(:image_content) { 'fake image content' }

      before do
        allow_any_instance_of(ActiveStorage::Blob).to receive(:byte_size).and_return(1.megabyte)
        allow_any_instance_of(ActiveStorage::Blob).to receive(:content_type).and_return('image/jpeg')

        quote.images.attach([
          {
            io: StringIO.new(image_content),
            filename: 'image1.jpg',
            content_type: 'image/jpeg'
          },
          {
            io: StringIO.new(image_content),
            filename: 'image2.png',
            content_type: 'image/png'
          }
        ])
      end

      it 'has images attached' do
        expect(quote.images).to be_attached
        expect(quote.images.count).to eq(2)
      end

      it 'can access image properties' do
        expect(quote.images.first.filename.to_s).to eq('image1.jpg')
        expect(quote.images.second.filename.to_s).to eq('image2.png')
      end
    end

    context 'acceptable image content types' do
      let(:image_content) { 'fake content' }

      before do
        allow_any_instance_of(ActiveStorage::Blob).to receive(:byte_size).and_return(1.megabyte)
      end

      ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'].each do |content_type|
        it "accepts #{content_type} images" do
          allow_any_instance_of(ActiveStorage::Blob).to receive(:content_type).and_return(content_type)

          quote.images.attach(
            io: StringIO.new(image_content),
            filename: "test.#{content_type.split('/').last}",
            content_type: content_type
          )

          expect(quote).to be_valid
        end
      end

      ['image/bmp', 'image/tiff', 'application/pdf', 'text/plain'].each do |content_type|
        it "rejects #{content_type} files" do
          allow_any_instance_of(ActiveStorage::Blob).to receive(:content_type).and_return(content_type)

          quote.images.attach(
            io: StringIO.new(image_content),
            filename: "test.#{content_type.split('/').last}",
            content_type: content_type
          )

          expect(quote).not_to be_valid
        end
      end
    end
  end

  describe 'complex scenarios' do
    describe 'quote associated with both works and movements' do
      let(:quote) { create(:quote) }
      let(:composer) { create(:composer) }
      let(:work) { create(:work, composer: composer) }
      let(:movement) { create(:movement, work: work) }

      before do
        create(:quote_detail, quote: quote, detailable: work, category: 'analysis')
        create(:quote_detail, quote: quote, detailable: movement, category: 'inspiration')
      end

      it 'can be accessed from both work and movement' do
        expect(work.quotes).to include(quote)
        expect(movement.quotes).to include(quote)
      end

      it 'maintains different categories for different associations' do
        work_detail = quote.quote_details.find_by(detailable: work)
        movement_detail = quote.quote_details.find_by(detailable: movement)

        expect(work_detail.category).to eq('analysis')
        expect(movement_detail.category).to eq('inspiration')
      end
    end

    describe 'quote with images and complex content' do
      let(:quote) { create(:quote, notes: 'This is a comprehensive analysis of the musical work.') }

      before do
        allow_any_instance_of(ActiveStorage::Blob).to receive(:byte_size).and_return(5.megabytes)
        allow_any_instance_of(ActiveStorage::Blob).to receive(:content_type).and_return('image/png')

        quote.images.attach(
          io: StringIO.new('fake image'),
          filename: 'analysis_chart.png',
          content_type: 'image/png'
        )
      end

      it 'handles complex content with images' do
        expect(quote).to be_valid
        expect(quote.images).to be_attached
        expect(quote.notes).to be_present
        expect(quote.title_with_author).to include('by')
      end
    end
  end

  describe 'performance and queries' do
    before do
      @quotes = create_list(:quote, 10)

      # Associate some quotes with works
      @quotes.first(5).each_with_index do |quote, i|
        nationality = create(:nationality, name: "WorkCountry#{i}", code: "WC#{i}")
        composer = create(:composer, first_name: "WorkComposer#{i}", last_name: "Test#{i}", nationality: nationality)
        work = create(:work, title: "Performance Work #{i}", composer: composer, opus: "Op. #{i + 200}")
        create(:quote_detail, quote: quote, detailable: work)
      end

      # Associate some quotes with movements
      @quotes.last(5).each_with_index do |quote, i|
        nationality = create(:nationality, name: "MovCountry#{i}", code: "MC#{i}")
        composer = create(:composer, first_name: "MovComposer#{i}", last_name: "Test#{i}", nationality: nationality)
        work = create(:work, title: "Performance Movement Work #{i}", composer: composer, opus: "Op. #{i + 300}")
        movement = create(:movement, title: "Performance Movement #{i}", work: work, position: 1)
        create(:quote_detail, quote: quote, detailable: movement)
      end
    end

    it 'efficiently loads works for quotes' do
      quote_with_work = @quotes.first
      expect(quote_with_work.works.count).to eq(1)
    end

    it 'efficiently loads movements for quotes' do
      quote_with_movement = @quotes.last
      expect(quote_with_movement.movements.count).to eq(1)
    end

    it 'handles large number of associations' do
      # Create a quote with many associations
      quote = create(:quote)
      # Use sequence to ensure unique attributes for each work
      works = 20.times.map do |i|
        nationality = create(:nationality, name: "Country#{i}", code: "C#{i.to_s.rjust(2, '0')}")
        composer = create(:composer, first_name: "Test#{i}", last_name: "Composer#{i}", nationality: nationality)
        create(:work, title: "Test Work #{i}", composer: composer, opus: "Op. #{i + 100}")
      end
      works.each { |work| create(:quote_detail, quote: quote, detailable: work) }

      expect(quote.works.count).to eq(20)
      expect(quote.quote_details.count).to eq(20)
    end
  end

  describe 'string representations and display' do
    let(:quote) { create(:quote, title: 'Musical Philosophy', author: 'Arthur Schopenhauer') }

    it 'has accessible attributes for display' do
      expect(quote.title).to be_present
      expect(quote.author).to be_present
      expect(quote.title_with_author).to be_present
    end

    context 'with very long content' do
      let(:long_notes) { 'This is a very long analysis. ' * 100 }
      let(:quote_with_long_notes) { create(:quote, notes: long_notes) }

      it 'handles long notes content' do
        expect(quote_with_long_notes).to be_valid
        expect(quote_with_long_notes.notes.length).to be > 1000
      end
    end
  end

  describe 'traits functionality' do
    describe 'classical_music_quote trait' do
      let(:classical_quote) { create(:quote, :classical_music_quote) }

      it 'has correct attributes for classical music quote' do
        expect(classical_quote.title).to eq('On Musical Expression')
        expect(classical_quote.author).to eq('Leonard Bernstein')
      end
    end

    describe 'philosophy_quote trait' do
      let(:philosophy_quote) { create(:quote, :philosophy_quote) }

      it 'has correct attributes for philosophy quote' do
        expect(philosophy_quote.title).to eq('The Meaning of Music')
        expect(philosophy_quote.author).to eq('Arthur Schopenhauer')
      end
    end

    describe 'composer_quote trait' do
      let(:composer_quote) { create(:quote, :composer_quote) }

      it 'has correct attributes for composer quote' do
        expect(composer_quote.title).to eq('Reflections on Composition')
        expect(composer_quote.author).to be_present
      end
    end
  end

  describe 'class methods and scopes' do
    # If you have scopes defined in the future, test them here
    # For example:
    # describe '.by_author' do
    #   let!(:bernstein_quote) { create(:quote, author: 'Leonard Bernstein') }
    #   let!(:beethoven_quote) { create(:quote, author: 'Ludwig van Beethoven') }
    #
    #   it 'returns quotes by specified author' do
    #     expect(Quote.by_author('Leonard Bernstein')).to include(bernstein_quote)
    #     expect(Quote.by_author('Leonard Bernstein')).not_to include(beethoven_quote)
    #   end
    # end
  end
end
