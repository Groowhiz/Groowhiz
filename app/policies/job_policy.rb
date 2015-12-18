class JobPolicy < ApplicationPolicy
  def create?
    done_by_owner_or_admin?
  end

  def update?
    done_by_owner_or_admin?
  end

  def sort?
    done_by_owner_or_admin?
  end

  def destroy?
    done_by_owner_or_admin?
  end

  def permitted_attributes
    attributes = record.attribute_names.map(&:to_sym)
    # attributes.delete(:minimum_value) if record.any_sold?
    # attributes.delete(:job_end_date) if project_finished?
    attributes
  end

  protected

  def project_finished?
    record.project.failed? || record.project.successful?
  end

  def done_by_owner_or_admin?
    record.project.user == user || user.try(:admin?)
  end
end

