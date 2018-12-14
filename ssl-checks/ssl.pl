#!/usr/bin/perl

$nginxConfigPath = "/etc/nginx/";
$mainConfigName = "nginx.conf";


$ignoredDomainsRaw = $ARGV[0];
@ignoredDomains = split /[\s,;|]+/g, $ignoredDomainsRaw;
%ignoredDomainsHash = ();
foreach $domain (@ignoredDomains) {
  $ignoredDomainsHash{$domain} = 1;
}

sub readFile {
  my ($filename) = @_;

  if(!($filename =~ /^\//)) {
    $filename = $nginxConfigPath . $filename;
  }

  open(my $handle, '<', $filename)
    or die('Error openning file '.$filename);
  $contents = '';
  while (<$handle>) {
    $contents .= $_;
  }
  close($handle);
  $contents =~ s/\#[^\n]*//g;
  return $contents;
}


#Join separate config files to one config
$mainConfig = readFile($mainConfigName);
while ($mainConfig =~ /(include\s+([^\n;]+);\s*)\n/) {
  $includeFilenameTemplate = $2;
  $includeCommand = quotemeta $1;

  if (!($includeFilenameTemplate=~/^\//)) {
    $includeFilenameTemplate = $nginxConfigPath . $includeFilenameTemplate;
  }

  if ($includeFilenameTemplate=~/\*/) {
    $filelist = `ls -1 $includeFilenameTemplate 2>/dev/null`;
    @filelist = split /\n/,$filelist;
    $concatenatedFiles = '';
    foreach $filename (@filelist) {
      $concatenatedFiles .= readFile($filename);
    }
    $mainConfig =~ s/$includeCommand/$concatenatedFiles/g;
  } else {
    $mainConfig =~ s/$includeCommand/$files{$includeFilename}/g;
  }
}

@servers = split /\s*server\s*\{/i, $mainConfig;
%allServerNames = ();
shift @servers;

foreach $config (@servers) {
  if($config =~ /listen [^;]*(ssl|http2)/ || $config =~ /\sssl\s+on\s*;/) {
    $config =~ /server_name\s+([^;]+);/;
    $serverNamesRaw = $1;
    @configServerNames = split /\s+/, $serverNamesRaw;
    foreach $serverName (@configServerNames) {
      if(!($serverName =~ /^(_|localhost)?$/) && !exists($ignoredDomainsHash{$serverName})) {
        $allServerNames{$serverName} = 1;
      }
    }
  }
}

print '{"data":['."\n";
$firstRow=1;
foreach $serverName (keys %allServerNames) {
  if(!$firstRow) {
    print ",\n";
  }
  $firstRow=0;
  print '{"{#DOMAIN}":"'.$serverName.'"}';
}
print "\n]}";
