class Avo::Filters::RoleFilter < Avo::Filters::SelectFilter
  self.name = "Role"

  def apply(request, query, value)
    query.where(role: value)
  end

  def options
    {
      customer: "Customer",
      admin: "Admin"
    }
  end
end 