class Avo::Actions::UpdateInventory < Avo::BaseAction
  self.name = "Update inventory"
  self.visible = -> do
    true
  end

  def fields
    field :inventory_count, as: :number, required: true
  end

  def handle(**args)
    records.each do |record|
      record.update(inventory_count: args[:inventory_count])
    end

    succeed "Successfully updated inventory for #{records.count} #{'product'.pluralize(records.count)}"
  end
end 