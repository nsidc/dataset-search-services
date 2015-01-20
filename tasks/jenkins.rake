def version_rb
  File.expand_path('../../lib/version.rb', __FILE__)
end

# Load will reload the version file so we can get the updated value
# after bumping it.
def current_version
  load version_rb
  Version::VERSION
end

namespace :jenkins do
  namespace :release do

    date = Time.now.strftime('%Y-%m-%d')

    desc 'Bump version part (patch/minor/major), set release date in CHANGELOG, make tag'
    task :bump, [:part] do |_t, args|
      args.with_defaults(part: 'patch')

      # bump VERSION in version.rb, stage version.rb
      sh "bundle exec bump #{args[:part]} --no-commit"
      sh "git add #{version_rb}"
      version = current_version

      # change "Unreleased" version to current version, with a release date of
      # today, stage CHANGELOG.md
      changelog_md = File.expand_path('../../CHANGELOG.md', __FILE__)
      sh %(sed -i "s/^## Unreleased$/## v#{version} (#{date})/" #{changelog_md})
      sh %(git add #{changelog_md})

      # add a link to the src of the new version in README so that plugin users
      # can easily find the correct version of the documentation
      readme_md = File.expand_path('../../README.md', __FILE__)
      repo_src_url = 'https://bitbucket.org/nsidc/vagrant-nsidc-plugin/src'

      # link to the version being released
      new_line = %(* [v#{version}](#{repo_src_url}/v#{version}/?at=v#{version}))

      # find where to add the new link - get the index of the latest version
      # link in the list
      lines_reversed = File.read(readme_md).split("\n").reverse
      index = lines_reversed.find_index do |line|
        line =~ %r{^\* \[v.*\]\(https://bitbucket\.org.*\)$}
      end

      # insert the new link, write the new file
      lines_reversed.insert(index, new_line)
      new_lines = lines_reversed.reverse.join("\n")
      File.open(readme_md, 'w') { |f| f.puts new_lines }

      # stage README.md with the new link
      sh %(git add #{readme_md})

      # commit changes and tag
      sh %(git commit -m "v#{version}")
      sh %(git tag v#{version})
    end

    desc 'git-push the release changes (the version bump commit and the version tag)'
    task :push do
      current_branch = `git rev-parse --abbrev-ref HEAD`.chomp
      sh "git push origin master #{ current_branch } --tags"
    end
  end
end
