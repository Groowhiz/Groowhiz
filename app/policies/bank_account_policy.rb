class BankAccountPolicy < ApplicationPolicy
  def show?
    done_by_owner_or_admin?
  end

  def request_refund?
    done_by_owner_or_admin?
  end

  def confirm?
    done_by_owner_or_admin?
  end

  def new?
    done_by_owner_or_admin?
  end

  def create?
    done_by_owner_or_admin?
  end

  def edit?
    done_by_owner_or_admin?
  end

  def update?
    done_by_owner_or_admin?
  end

  def permitted_attributes
    [:bank_id, :name, :agency, :account, :owner_name, :owner_document, :account_digit, :agency_digit, :input_bank_number]
  end

  protected
  def done_by_owner_or_admin?
    record.user == user || user.try(:admin?)
  end
end


