class QuoteDetail < ApplicationRecord
  belongs_to :quote
  belongs_to :detailable, polymorphic: true

  validate :detailable_constraints

  private

  def detailable_constraints
    # 1) If we are attaching to a Work:
    if detailable_type == "Work"
      work = Work.find(detailable_id)

      # a) That work must have NO movements:
      if work.movements.exists?
        errors.add(:detailable, "Work ##{work.id} has movements, so you cannot attach a quote‐location directly to it.")
      end

      # b) Also, if the parent quote already has any locations on movements
      #    beneath this same work, that's disallowed. (Because you can't mix.)
      if quote.quote_details
             .where(detailable_type: "Movement")
             .includes(:detailable)
             .pluck(:detailable_id)
             .map { |mv_id| Movement.find(mv_id).work_id }
             .include?(work.id)
        errors.add(
          :base,
          "Cannot add a work-level location for Work ##{work.id} when this quote is already located on a movement of that work."
        )
      end

    # 2) If we are attaching to a Movement:
    elsif detailable_type == "Movement"
      mv   = Movement.find(detailable_id)
      parent = mv.work

      # a) If the parent work has any existing *work-level* locations on this same quote, disallow:
      if quote.quote_details
             .where(detailable_type: "Work", detailable_id: parent.id)
             .exists?
        errors.add(
          :base,
          "Cannot add a movement‐level location under Movement ##{mv.id} because this quote is already attached at the work level (Work ##{parent.id})."
        )
      end
    else
      errors.add(:detailable, "must be either a Work or a Movement")
    end
  end
end
