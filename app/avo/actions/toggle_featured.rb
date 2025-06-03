class Avo::Actions::ToggleFeatured < Avo::BaseAction
  self.name = "Toggle featured"
  self.visible = -> do
    true
  end

  def handle(**args)
    @records = Product.where(id: args[:fields][:avo_resource_ids])
    
    @records.each do |record|
      record.update(featured: !record.featured)
    end

    succeed "Successfully toggled featured status!"
  end
end 