class DepartementSerializer < BaseSerializer

  attributes :id,
             :code,
             :name

  def name
  	object.admin_name2
  end

  def code
  	object.admin_code2
  end

end