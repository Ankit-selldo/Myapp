class Avo::Actions::PublishPost < Avo::BaseAction
  self.name = "Publish post"
  self.visible = -> do
    true
  end

  def handle(**args)
    records.each do |record|
      record.update(
        status: :published,
        published_at: Time.current
      )
    end

    succeed "Successfully published #{records.count} #{'post'.pluralize(records.count)}"
  end
end 