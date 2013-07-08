#!/usr/bin/perl -w
use strict;
use warnings;
use File::Find;
#use Digest::MD5 qw(md5_hex);


######BE CAREFUL OF THIS LOCATION######
my $targetDir = '/movies/';
#######IT WILL GET ERASED###############

my %movieKeys = ( #tags to convert to folder names
xHD =>	'Hi-Def',
xSD =>	'Standard Definition',
xANI =>	'Animation',
xADV =>	'Adventure',
xACT =>	'Action',
xFAM =>	'Family',
xFAN =>	'Fantasy',
xSCI =>	'Sci-Fi',
xCOM =>	'Comedy',
xROM =>	'Romance',
xDRA =>	'Drama',
xMYS =>	'Mystery',
xTHR =>	'Thriller',
xCRI =>	'Crime',
x007 =>	'James Bond - 007',
xBIO =>	'Biography',
xSPO =>	'Sport',
xHOR =>	'Horror',
xWES =>	'Western',
xWAR =>	'War',
xHIS =>	'History',
xSTAR =>	'Star Trek',
xMUS =>	'Music',
xSHO =>	'Short',
xDOC =>	'Documentary',
xHP =>	'Harry Potter');
#my %moviesByGenre;
my $totalFileSize = 0;
my @dirList = ( #listing of directories to parse
    '/media/Media/data/',
    '/media/Rhodium/data/',
    '/media/Yttrium/data/'
);
my @staticDirs = (
    '/media/Media/torrentDownload/'
);
if (-d $targetDir){ #check if target exists and prompt to delete
    print "Target Exists! Attempt to delete? (Y/N): \n";
    my $answer = 'blarg';
    while(!($answer =~ /^Y/i) or !($answer =~/^N/i)){
        chomp ($answer = <STDIN>);        
        
        if($answer =~ /^Y/i){
            system('rm','-rf', $targetDir);
            last;
        }
        elsif($answer =~ /^n/i){
            
        }
        else
        {
            print ("Please enter (Y)es or (N)o.\n");
        }
    }

}
mkdir $targetDir; #create target directory
foreach my $tag (keys %movieKeys){ #make directories for symlinks
    my $fullDir = $targetDir . $movieKeys{$tag};
    mkdir $fullDir;
#    $moviesByGenre{$tag} = undef;
}

foreach my $dirName (@dirList){
find(\&isFileMKV, $dirName);
}

print("Total file size: ", $totalFileSize, "\n");








sub isFileMKV {
    my $t = $File::Find::name;
    $totalFileSize += -s $t;
    my $r = $_;
    $r =~ s/\.mkv//i;
    if($t =~ /.mkv/i  && ($t =~ /x[S,H]D/)){
        my @array = (split(' ', $r));
        my @withoutKeys = ($t);
        for (my $i = 0; $i < scalar(@array); $i++){
            if ( $array[$i] =~ /^x$/ ){
                print("Possible bad file tag in file: ", $t, "\n");
            }
            if($array[$i] =~/^[xX]\w{2,4}/ and !exists $movieKeys{$array[$i]}){
                print("Possible bad file tag in file: ", $t, "\n");
            }
            if (!exists $movieKeys{$array[$i]}){
                push(@withoutKeys, $array[$i]);
            }   
        }
        foreach my $genre (keys %movieKeys){   
            if($r =~ /$genre/){
                #$moviesByGenre{$genre}{md5_hex($t)} = \@array;
                my $correctedFilename = $withoutKeys[1];
                for (my $i = 2; $i < scalar(@withoutKeys); $i++){
                    $correctedFilename .= " ";
                    $correctedFilename .= $withoutKeys[$i];
                    
                }
                $correctedFilename .= ".mkv";
 
                symlink $t, $targetDir . "/" . $movieKeys{$genre} . "/" . $correctedFilename;
            }
        }
        
    }
}
