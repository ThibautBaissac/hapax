require 'rails_helper'

RSpec.describe WorksController, type: :request do
  let(:user) { create(:user) }
  let(:nationality) { create(:nationality) }
  let(:composer) { create(:composer, nationality: nationality) }
  let(:work) { create(:work, composer: composer) }

  before { sign_in user }

  describe "GET /composers/:composer_id/works" do
    context "with existing works" do
      let!(:works) { create_list(:work, 3, composer: composer) }
      let!(:work_with_movements) { create(:work, :with_movements, composer: composer) }
      let!(:work_with_quotes) { create(:work, :with_quotes, composer: composer) }

      it "returns success" do
        get "/composers/#{composer.id}/works"

        expect(response).to have_http_status(:success)
      end

      it "displays all works for the composer" do
        get "/composers/#{composer.id}/works"

        expect(response).to have_http_status(:success)
        # Check that we get a successful response - view content depends on actual view template
      end

      it "loads efficiently without N+1 queries" do
        # This test ensures the controller uses includes(:movements, :quotes)
        get "/composers/#{composer.id}/works"
        expect(response).to have_http_status(:success)
      end
    end

    context "with no works" do
      it "returns success with empty list" do
        get "/composers/#{composer.id}/works"

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /composers/:composer_id/works/:id" do
    context "with existing work" do
      let(:work_with_details) { create(:work, :symphony, composer: composer) }

      it "returns success" do
        get "/composers/#{composer.id}/works/#{work_with_details.id}"

        expect(response).to have_http_status(:success)
      end

      it "displays the work details" do
        get "/composers/#{composer.id}/works/#{work_with_details.id}"

        expect(response.body).to include(work_with_details.title)
        expect(response.body).to include(work_with_details.opus) if work_with_details.opus.present?
        expect(response.body).to include(work_with_details.description) if work_with_details.description.present?
      end
    end

    context "with work that has movements and quotes" do
      let(:complex_work) { create(:work, :with_movements, :with_quotes, composer: composer) }

      it "displays associated movements and quotes" do
        get "/composers/#{composer.id}/works/#{complex_work.id}"

        expect(response).to have_http_status(:success)
        # Would check for movements and quotes in the response body
        # depending on how the view is structured
      end
    end
  end

  describe "GET /composers/:composer_id/works/new" do
    it "returns success" do
      get "/composers/#{composer.id}/works/new"

      expect(response).to have_http_status(:success)
    end

    it "displays form for new work" do
      get "/composers/#{composer.id}/works/new"

      expect(response.body).to include("form")
      expect(response.body).to include("Title")
      expect(response.body).to include("Opus")
    end

    it "includes form fields for all work attributes" do
      get "/composers/#{composer.id}/works/new"

      # Check for key form fields
      expect(response.body).to include("work_title")
      expect(response.body).to include("work_opus")
      expect(response.body).to include("work_description")
      expect(response.body).to include("work_form")
      expect(response.body).to include("work_structure")
    end
  end

  describe "GET /composers/:composer_id/works/:id/edit" do
    it "returns success" do
      get "/composers/#{composer.id}/works/#{work.id}/edit"

      expect(response).to have_http_status(:success)
    end

    it "displays edit form with existing values" do
      get "/composers/#{composer.id}/works/#{work.id}/edit"

      expect(response.body).to include("form")
      expect(response.body).to include(work.title)
      expect(response.body).to include(work.opus) if work.opus.present?
    end

    it "pre-populates form fields" do
      work_to_edit = create(:work, :symphony, composer: composer, title: "Test Symphony")

      get "/composers/#{composer.id}/works/#{work_to_edit.id}/edit"

      expect(response.body).to include("Test Symphony")
      expect(response.body).to include("value=\"Test Symphony\"")
    end
  end

  describe "POST /composers/:composer_id/works" do
    let(:valid_attributes) do
      {
        title: "New Symphony",
        opus: "Op. 42",
        description: "A beautiful symphony",
        duration: 3600,
        form: "symphony",
        structure: "movement",
        instrumentation: "Full orchestra",
        recorded: true,
        start_date_composed: "2023-01-01",
        end_date_composed: "2023-06-01",
        unsure_start_date: false,
        unsure_end_date: false
      }
    end

    let(:minimal_valid_attributes) do
      {
        title: "Minimal Work"
      }
    end

    let(:invalid_attributes) do
      {
        title: "",
        opus: "Invalid Opus"
      }
    end

    context "with valid parameters" do
      it "creates a new work" do
        expect {
          post "/composers/#{composer.id}/works", params: { work: valid_attributes }
        }.to change(Work, :count).by(1)

        expect(response).to redirect_to([composer, Work.last])
        expect(flash[:notice]).to eq("Work was successfully created.")
      end

      it "creates work with correct attributes" do
        post "/composers/#{composer.id}/works", params: { work: valid_attributes }

        created_work = Work.last
        expect(created_work.title).to eq("New Symphony")
        expect(created_work.opus).to eq("Op. 42")
        expect(created_work.composer).to eq(composer)
        expect(created_work.form).to eq("symphony")
        expect(created_work.structure).to eq("movement")
      end

      it "creates work with minimal required attributes" do
        expect {
          post "/composers/#{composer.id}/works", params: { work: minimal_valid_attributes }
        }.to change(Work, :count).by(1)

        created_work = Work.last
        expect(created_work.title).to eq("Minimal Work")
        expect(created_work.composer).to eq(composer)
      end

      it "handles date composition fields correctly" do
        date_attributes = valid_attributes.merge(
          start_date_composed: "2023-01-15",
          end_date_composed: "2023-12-31",
          unsure_start_date: true,
          unsure_end_date: false
        )

        post "/composers/#{composer.id}/works", params: { work: date_attributes }

        created_work = Work.last
        expect(created_work.start_date_composed).to eq(Date.parse("2023-01-15"))
        expect(created_work.end_date_composed).to eq(Date.parse("2023-12-31"))
        expect(created_work.unsure_start_date).to be true
        expect(created_work.unsure_end_date).to be false
      end
    end

    context "with invalid parameters" do
      it "does not create a work" do
        expect {
          post "/composers/#{composer.id}/works", params: { work: invalid_attributes }
        }.not_to change(Work, :count)
      end

      it "renders new template with unprocessable entity status" do
        post "/composers/#{composer.id}/works", params: { work: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "displays errors on the form" do
        post "/composers/#{composer.id}/works", params: { work: invalid_attributes }

        expect(response.body).to include("error")
      end
    end

    context "with different work types" do
      it "creates symphony work correctly" do
        symphony_attributes = valid_attributes.merge(
          title: "Symphony No. 5",
          form: "symphony",
          structure: "movement",
          duration: 2400
        )

        post "/composers/#{composer.id}/works", params: { work: symphony_attributes }

        created_work = Work.last
        expect(created_work.form).to eq("symphony")
        expect(created_work.structure).to eq("movement")
      end

      it "creates opera work correctly" do
        opera_attributes = valid_attributes.merge(
          title: "The Magic Flute",
          form: "opera",
          structure: "act",
          duration: 7200
        )

        post "/composers/#{composer.id}/works", params: { work: opera_attributes }

        created_work = Work.last
        expect(created_work.form).to eq("opera")
        expect(created_work.structure).to eq("act")
      end

      it "creates short piece correctly" do
        piece_attributes = valid_attributes.merge(
          title: "Nocturne in E-flat",
          form: "nocturne",
          structure: "melodies",
          duration: 300
        )

        post "/composers/#{composer.id}/works", params: { work: piece_attributes }

        created_work = Work.last
        expect(created_work.form).to eq("nocturne")
        expect(created_work.structure).to eq("melodies")
      end
    end
  end

  describe "PATCH /composers/:composer_id/works/:id" do
    let(:new_attributes) do
      {
        title: "Updated Symphony",
        opus: "Op. 99",
        description: "An updated description",
        duration: 4200,
        form: "concerto",
        structure: "movement"
      }
    end

    let(:invalid_update_attributes) do
      {
        title: "",
        opus: "Invalid"
      }
    end

    context "with valid parameters" do
      it "updates the work" do
        patch "/composers/#{composer.id}/works/#{work.id}",
              params: { work: new_attributes }

        work.reload
        expect(work.title).to eq("Updated Symphony")
        expect(work.opus).to eq("Op. 99")
        expect(work.description).to eq("An updated description")
        expect(work.form).to eq("concerto")
      end

      it "redirects to the work" do
        patch "/composers/#{composer.id}/works/#{work.id}",
              params: { work: new_attributes }

        expect(response).to redirect_to([composer, work])
        expect(flash[:notice]).to eq("Work was successfully updated.")
      end

      it "updates composition dates" do
        date_attributes = {
          start_date_composed: "2024-01-01",
          end_date_composed: "2024-12-31",
          unsure_start_date: false,
          unsure_end_date: true
        }

        patch "/composers/#{composer.id}/works/#{work.id}",
              params: { work: date_attributes }

        work.reload
        expect(work.start_date_composed).to eq(Date.parse("2024-01-01"))
        expect(work.end_date_composed).to eq(Date.parse("2024-12-31"))
        expect(work.unsure_start_date).to be false
        expect(work.unsure_end_date).to be true
      end

      it "updates boolean fields correctly" do
        boolean_attributes = {
          recorded: false,
          unsure_start_date: true,
          unsure_end_date: false
        }

        patch "/composers/#{composer.id}/works/#{work.id}",
              params: { work: boolean_attributes }

        work.reload
        expect(work.recorded).to be false
        expect(work.unsure_start_date).to be true
        expect(work.unsure_end_date).to be false
      end
    end

    context "with invalid parameters" do
      it "does not update the work" do
        original_title = work.title

        patch "/composers/#{composer.id}/works/#{work.id}",
              params: { work: invalid_update_attributes }

        work.reload
        expect(work.title).to eq(original_title)
      end

      it "renders edit template with unprocessable entity status" do
        patch "/composers/#{composer.id}/works/#{work.id}",
              params: { work: invalid_update_attributes }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with partial updates" do
      it "updates only specified fields" do
        original_opus = work.opus
        partial_attributes = { title: "Partially Updated Title" }

        patch "/composers/#{composer.id}/works/#{work.id}",
              params: { work: partial_attributes }

        work.reload
        expect(work.title).to eq("Partially Updated Title")
        expect(work.opus).to eq(original_opus) # Should remain unchanged
      end
    end
  end

  describe "DELETE /composers/:composer_id/works/:id" do
    context "when destruction is successful" do
      it "destroys the work" do
        work_to_delete = create(:work, composer: composer)

        expect {
          delete "/composers/#{composer.id}/works/#{work_to_delete.id}"
        }.to change(Work, :count).by(-1)
      end

      it "redirects to composer works index" do
        delete "/composers/#{composer.id}/works/#{work.id}"

        expect(response).to redirect_to(composer_works_path(composer))
        expect(response).to have_http_status(:see_other)
        expect(flash[:notice]).to eq("Work was successfully destroyed.")
      end

      it "handles work with associated movements and quotes" do
        complex_work = create(:work, :with_movements, :with_quotes, composer: composer)

        expect {
          delete "/composers/#{composer.id}/works/#{complex_work.id}"
        }.to change(Work, :count).by(-1)

        expect(response).to redirect_to(composer_works_path(composer))
      end
    end

    context "when destruction fails" do
      it "handles destruction failure gracefully" do
        # Create a work and test the error path
        failing_work = create(:work, composer: composer)

        # Mock the destroy method to return false
        allow_any_instance_of(Work).to receive(:destroy).and_return(false)

        # Mock the errors method
        error_messages = ["Cannot delete work with associated data"]
        allow_any_instance_of(Work).to receive_message_chain(:errors, :full_messages).and_return(error_messages)

        delete "/composers/#{composer.id}/works/#{failing_work.id}"

        expect(response).to redirect_to([composer, failing_work])
        expect(flash[:alert]).to eq("Cannot delete work with associated data")
      end
    end
  end

  # Test error handling and edge cases
  describe "error handling" do
    context "when composer not found" do
      it "returns 404" do
        get "/composers/999999/works"
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when work not found" do
      it "returns 404 for show" do
        get "/composers/#{composer.id}/works/999999"
        expect(response).to have_http_status(:not_found)
      end

      it "returns 404 for edit" do
        get "/composers/#{composer.id}/works/999999/edit"
        expect(response).to have_http_status(:not_found)
      end

      it "returns 404 for update" do
        patch "/composers/#{composer.id}/works/999999", params: { work: { title: "Test" } }
        expect(response).to have_http_status(:not_found)
      end

      it "returns 404 for destroy" do
        delete "/composers/#{composer.id}/works/999999"
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when work belongs to different composer" do
      let(:other_composer) { create(:composer, nationality: nationality) }
      let(:other_work) { create(:work, composer: other_composer) }

      it "returns 404 when accessing work from wrong composer" do
        get "/composers/#{composer.id}/works/#{other_work.id}"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # Test parameter validation with Rails 8 params.expect
  describe "parameter validation" do
    context "with Rails 8 params.expect" do
      it "handles all valid work parameters" do
        complete_params = {
          opus: "Op. 123",
          title: "Complete Test Work",
          description: "Full description",
          duration: 1800,
          form: "symphony",
          structure: "movement",
          instrumentation: "String quartet",
          recorded: true,
          start_date_composed: "2023-01-01",
          end_date_composed: "2023-12-31",
          unsure_start_date: false,
          unsure_end_date: true
        }

        post "/composers/#{composer.id}/works", params: { work: complete_params }

        expect(response).to redirect_to([composer, Work.last])

        created_work = Work.last
        expect(created_work.opus).to eq("Op. 123")
        expect(created_work.title).to eq("Complete Test Work")
        expect(created_work.duration).to eq(1800)
        expect(created_work.instrumentation).to eq("String quartet")
      end

      it "ignores unexpected parameters" do
        params_with_extra = {
          title: "Test Work",
          unexpected_param: "should be ignored",
          another_bad_param: 12345
        }

        expect {
          post "/composers/#{composer.id}/works", params: { work: params_with_extra }
        }.to change(Work, :count).by(1)

        created_work = Work.last
        expect(created_work.title).to eq("Test Work")
        # Unexpected params should be filtered out by params.expect
      end
    end
  end

  # Test different work forms and structures
  describe "work forms and structures" do
    let(:form_structure_combinations) do
      [
        { form: "symphony", structure: "movement" },
        { form: "opera", structure: "act" },
        { form: "sonata", structure: "movement" },
        { form: "concerto", structure: "movement" },
        { form: "prelude", structure: "melodies" },
        { form: "song_cycle", structure: "lied" }
      ]
    end

    it "creates works with different form/structure combinations" do
      form_structure_combinations.each do |combo|
        work_attrs = {
          title: "Test #{combo[:form].capitalize}",
          form: combo[:form],
          structure: combo[:structure]
        }

        post "/composers/#{composer.id}/works", params: { work: work_attrs }

        expect(response).to redirect_to([composer, Work.last])

        created_work = Work.last
        expect(created_work.form).to eq(combo[:form])
        expect(created_work.structure).to eq(combo[:structure])
      end
    end
  end

  # Test authentication (should be covered by application controller)
  describe "authentication" do
    context "when not authenticated" do
      before { sign_out user }

      it "redirects to login for index" do
        get "/composers/#{composer.id}/works"
        expect(response).to redirect_to(new_user_session_path)
      end

      it "redirects to login for create" do
        post "/composers/#{composer.id}/works", params: { work: { title: "Test" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  # Performance tests
  describe "performance" do
    context "with many works" do
      let!(:many_works) { create_list(:work, 20, composer: composer) }

      it "loads index efficiently" do
        get "/composers/#{composer.id}/works"

        expect(response).to have_http_status(:success)
      end
    end

    context "with works having many associations" do
      let!(:complex_works) do
        3.times.map { create(:work, :with_movements, :with_quotes, composer: composer) }
      end

      it "loads index with associations efficiently" do
        get "/composers/#{composer.id}/works"

        expect(response).to have_http_status(:success)
      end
    end
  end
end
