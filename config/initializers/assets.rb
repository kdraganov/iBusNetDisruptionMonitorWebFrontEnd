# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'
Rails.application.config.assets.precompile += %w( disruptionList.js )
Rails.application.config.assets.precompile += %w( SampleStripMap.png )
Rails.application.config.assets.precompile += %w( SampleMap.png )
Rails.application.config.assets.precompile += %w( SampleMapOverview.png )
Rails.application.config.assets.precompile += %w( hide.png )
Rails.application.config.assets.precompile += %w( unhide.png )
Rails.application.config.assets.precompile += %w( inbound.png )
Rails.application.config.assets.precompile += %w( outbound.png )
Rails.application.config.assets.precompile += %w( details.png )
Rails.application.config.assets.precompile += %w( comments.png )
Rails.application.config.assets.precompile += %w( edit.png )

Rails.application.config.assets.precompile += %w( down_arrow.gif )
Rails.application.config.assets.precompile += %w( up_arrow.gif )
# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
