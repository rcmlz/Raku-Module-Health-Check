#!/usr/bin/env raku

use JSON::Fast "sorted-keys";

sub MAIN (Str $base-folder, Str $out-file ) {
    check-health($base-folder, $out-file)
}

sub check-health(Str $base-folder, Str $out-file) {
    
    my @stack = $base-folder.IO;
    my @files = gather while @stack {
        with @stack.pop {
            when $_.d { @stack.append: .dir }
            .take when .extension.lc eq 'json'
        }
    }

    # given that list off all .json files look-alike META6.json,
    # try to install all modules found under key depends, build-depends, test-depends
    # something like this:
    # {
    #  "depends": [
    #    "Test",
    #    "Test::META"
    #   ]
    # }
    my $modules = [].SetHash;
    for @files -> $f {
        try {
            my %json = from-json($f.slurp);
            if %json.EXISTS-KEY('depends') {
                $modules.set(%json.<depends>);
            }elsif %json.EXISTS-KEY('build-depends') {
                $modules.set(%json.<build-depends>);
            }elsif %json.EXISTS-KEY('test-depends') {
                $modules.set(%json.<test-depends>);            
            }
        }
        note "Processing failed for $f " ~ $! if $!;
    }
    
    my Str $system = "linux";
    $system = "windows" if $*DISTRO.is-win;
    $system = "macos"   if $*DISTRO.name ~~ /macos/;    

    my %total = $system => {  dry => [],
                              gold => [], 
                              silver => [], 
                              bronze => [],
                              bogus => [],
                              impossible => []
                          }
                ;

    my $cmd = 'zef install --error --fetch-degree=4 --test-degree=2 %s';
    my $gold = '"%s"';
    my $silver = $gold;
    my $bronze = '--/test-depends "%s"';
    my $bogus = '--/test --/test-depends "%s"';

    my @silver-candidates;
    my @bronze-candidates;
    my @bogus-candidates;

    # try installing as user in dry mode
#    testing_env_mode(0);
#    for $modules.keys.sort -> Str $m {
#        status($m);
#        my $c = $cmd.sprintf($gold).sprintf("--dry " ~ $m);
#        say $c;
#        my $p = shell($c);
#        my Int $exit-code = $p.exitcode.Int;
#        my $status = 'dry';
#        if $exit-code == 0 {
#            %total{$system}{$status}.push: $m;            
#        }
#    }

    # try installing with all tests activated
    testing_env_mode(1);
    for $modules.keys.sort -> Str $m {
        status($m);
        my $c = $cmd.sprintf($gold).sprintf($m);
        say $c;
        my $p = shell($c);
        my Int $exit-code = $p.exitcode.Int;
        my $status = 'gold';
        if $exit-code != 0 {
            @silver-candidates.push: $m; 
        }else{
            %total{$system}{$status}.push: $m;            
        }
    }

    # try again without AUTHOR and NETWORK etc. tests
    testing_env_mode(0);
    for @silver-candidates.sort -> Str $m {
        status($m);
        my $c = $cmd.sprintf($silver).sprintf($m);
        say $c;
        my $p = shell($c);
        my Int $exit-code = $p.exitcode.Int;
        my $status = 'silver';
        if $exit-code != 0 {
            @bronze-candidates.push: $m; 
        }else{
            %total{$system}{$status}.push: $m;            
        }
    }

    # try again dependency test deactivated
    for @bronze-candidates.sort -> Str $m {
        status($m);
        my $c = $cmd.sprintf($bronze).sprintf($m);
        say $c;
        my $p = shell($c);
        my Int $exit-code = $p.exitcode.Int;
        my $status = 'bronze';
        if $exit-code != 0 {
            @bogus-candidates.push: $m; 
        }else{
            %total{$system}{$status}.push: $m;            
        }
    }

    # try again all tests deactivated
    for @bogus-candidates.sort -> Str $m {
        status($m);
        my $c = $cmd.sprintf($bogus).sprintf($m);
        say $c;
        my $p = shell($c);
        my Int $exit-code = $p.exitcode.Int;
        my $status = 'bogus';
        $status = 'impossible' if $exit-code != 0;
        %total{$system}{$status}.push: $m;            
    }

    my $res = to-json %total;
    say $res;
    spurt $out-file, $res;
}

sub status($m){
    my $msg = "=== $m ===";
    say '=' x $msg.comb.elems;
    say $msg;
    say '=' x $msg.comb.elems;
}

sub testing_env_mode(UInt $to=1) {
    %*ENV<AUTHOR_TESTING> = $to;
    %*ENV<NETWORK_TESTING> = $to;
}