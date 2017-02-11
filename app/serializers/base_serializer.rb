class BaseSerializer < ActiveModel::Serializer

  delegate :current_user, to: :scope

end