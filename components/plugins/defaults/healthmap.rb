=begin
    Copyright 2010-2014 Tasos Laskos <tasos.laskos@gmail.com>
    All rights reserved.
=end

# Generates a simple list of safe/unsafe URLs.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class Arachni::Plugins::HealthMap < Arachni::Plugin::Base

    is_distributable

    def run
        wait_while_framework_running

        auditstore = framework.auditstore

        sitemap  = auditstore.sitemap.keys.map { |url| url.split( '?' ).first }.uniq
        sitemap |= issue_urls = auditstore.issues.map { |issue| issue.vector.action }.uniq

        return if sitemap.size == 0

        issue_cnt = 0
        map = []
        sitemap.sort.each do |url|
            next if !url

            if issue_urls.include?( url )
                map << { 'with_issues' => url }
                issue_cnt += 1
            else
                map << { 'with_issues' => url }
            end
        end

        register_results(
            'map'              => map,
            'total'            => map.size,
            'without_issues'   => map.size - issue_cnt,
            'with_issues'      => issue_cnt,
            'issue_percentage' => ((issue_cnt.to_f / map.size.to_f) * 100).round
        )
    end

    def self.merge( results )
        merged = {
            'map'              => [],
            'total'            => 0,
            'without_issues'   => 0,
            'with_issues'      => 0,
            'issue_percentage' => 0
        }

        results.each do |healthmap|
            merged['map']            |= healthmap['map']
            merged['total']          += healthmap['total']
            merged['without_issues'] += healthmap['without_issues']
            merged['with_issues']    += healthmap['with_issues']
        end

        merged['issue_percentage'] =
            ( ( merged['with_issues'].to_f / merged['total'].to_f ) * 100 ).round

        merged
    end

    def self.info
        {
            name:        'Health map',
            description: %q{Generates a simple list of safe/unsafe URLs.},
            author:      'Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>',
            version:     '0.1.5'
        }
    end

end
