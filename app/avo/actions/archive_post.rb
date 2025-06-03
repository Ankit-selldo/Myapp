class Avo::Actions::ArchivePost < Avo::BaseAction
  self.name = "Archive post"
  self.visible = -> do
    true
  end

  def handle(**args)
    records.each do |record|
      record.update(status: :archived)
    end

    succeed "Successfully archived #{records.count} #{'post'.pluralize(records.count)}"
  end
end 