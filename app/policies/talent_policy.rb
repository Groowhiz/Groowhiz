class TalentPolicy < ApplicationPolicy

  self::UserScope = Struct.new(:current_user, :user, :scope) do
    def resolve
      if current_user.try(:admin?) || current_user == user
        scope.without_state('deleted')
      else
        scope.without_state(['deleted'])
      end
    end
  end

  def create?
    done_by_owner_or_admin?
  end

  def update?
    create?
  end

  # def update_account?
  #   record.account.invalid? ||
  #     ['online', 'waiting_funds', 'successful', 'failed'].exclude?(record.state) || is_admin?
  # end

  # def send_to_analysis?
  #   create?
  # end

  def publish?
    create? && record.approved?
  end

  def permitted_attributes
    if user.present?
      p "Did I come to talent policy permitted_attributes?"
      p_attr = record.attribute_names.map(&:to_sym)
      p "Did I come to talent policy permitted_attributes record? #{p_attr}"

      p_attr << user_attributes
      p "Did I come to talent policy permitted_attributes user? #{p_attr}"

      p_attr << talent_attributes
      # p_attr << talent_videos_attributes
      # p "Did I come to talent policy permitted_attributes talent video? #{p_attr}"
      # p "Did I come to talent policy permitted_attributes flattened? #{p_attr.flatten}"

      p_attr.flatten
    else
      p "Oh no came here"
      [:about_html, :video_url, :uploaded_image, :headline, :budget,
                 user_attributes, posts_attributes, budget_attributes, reward_attributes, account_attributes]
    end
  end
  #
  # def budget_attributes
  #   { budgets_attributes: [:id, :name, :value, :_destroy] }
  # end

  def user_attributes
    { user_attributes:  [ User.attr_accessible[:default].to_a.map(&:to_sym), :id,
                          bank_account_attributes: [
                            :id, :bank_id, :agency, :agency_digit, :account,
                            :account_digit, :owner_name, :owner_document
                          ],
                          links_attributes: [:id, :_destroy, :link]
                        ] }
  end

  def posts_attributes
    { posts_attributes: [:_destroy, :title, :comment_html, :exclusive, :id]}
  end

  def reward_attributes
    { rewards_attributes: [:_destroy, :id, :maximum_contributions,
                          :description, :deliver_at, :minimum_value] }
  end

  def account_attributes
    if done_by_owner_or_admin?
      { account_attributes: ProjectAccount.attribute_names.map(&:to_sym) }
    end
  end

  def talent_videos_attributes
    { talent_videos_attributes: [:_destroy, :id, :video_url,
                           :video_thumbnail, :video_embed_url] }
  end

  def talent_attributes
    {
        talent: [:title, :description, :category_id,
        talent_videos_attributes]
    }
  end

end

