###############################################################################
#
#   Package: NaturalDocs::TopicsTools
#
###############################################################################
#
#   This package contains functions that can be used to modify %parsedFiles. 
#	This has been implemented in order to add more options to NaturalDocs, 
#	such as showing parents functions in a class documentation, or sorting topics.
#
###############################################################################

use strict;
use integer;

use NaturalDocs::Parser::ParsedTopic;
use NaturalDocs::Builder::HTMLBase;

package NaturalDocs::TopicsTools;

###############################################################################
# Group: Constants

#
#	Constant: MAX_FUNCTIONS
#
#	This constant is used to separate functions by their first letter, if there are more
#	than MAX_FUNCTIONS in the same group
#

my $MAX_FUNCTIONS = 20;

###############################################################################
# Group: Interface Functions

#
#   Function: WorkOnParsedFiles
#
#	This method is an interface method that can be used to format parsedFiles the way we want.
#	In our case, it sorts topics, and adds parents classes.
#
#	Parameter:
#		
#		parsedFiles - A reference to the hash containing all parsedFiles
#

sub WorkOnParsedFiles #(parsedFilesRef)
{
    my ($self, $parsedFiles) = @_;
	
	foreach my $parsedFile (values %$parsedFiles)
	{
		$self->SortByName($parsedFile);
	}	
	$self->AddParentsMethods($parsedFiles);	
}

###############################################################################
# Group: Inheritance Functions

#
#   Function: AddParentsMethods
#
#	This method adds to every class in the current parsedFiles all inherited methods from all their known parents
#	(grand-parents, and so on...), and specifies from which parent they come from. Those methods will be added at 
#	the end of the current parsedFile.
#
#	Parameter:
#		
#		parsedFiles - A reference to the hash containing all parsedFiles
#

sub AddParentsMethods #(parsedFilesRef)
{
    my ($self, $parsedFiles) = @_;
	
	# For each file, we check every class
	foreach my $file (keys %$parsedFiles)
	{
		my $parsedFile = $parsedFiles->{$file};
		
		# We get the class on the given file
		my ($className, $index) = $self->GetClassName($parsedFile);	
		
		if ($className)
		{
			my $topicClass = $parsedFile->[$index];
			my @inheritedMethods;
			my %parsedFilesTemp = %$parsedFiles;
			my @processedParents;
			
			$self->SearchForParentsAndGetMethods(\@inheritedMethods, $topicClass, \%parsedFilesTemp
												, $file, $parsedFile, \@processedParents);
			
			push @$parsedFile, @inheritedMethods;
			
			# Once we got all new topics in our parsed file, we can make it look nicer
			$self->CountFunctionsAndJumpLines($parsedFile);
		}	
	}
}

#
#   Function: SearchForParentsAndGetMethods
#
#	For the given class, searches for parents and add their methods to @inheritedMethods.
#	May be called recursevely to get the whole "tree" of classes.
#
#   Parameters:
#
#		inheritedMethods - An array where we store inherited methods
#		topicClass - The topic containing the class we're looking for parents
#		parsedFiles - A reference to the hash containing all parsedFiles
#		originalFile - The complete path to the file containing the class we were looking for its parents in the first place
#						(used for recursion)
#		originalTopicClass - The topic containing the class we were looking for its parents in the first place
#		processedParents - An array containing all parents already processed for the original class
#

sub SearchForParentsAndGetMethods 	#(inheritedMethods, topicClass, parsedFiles, originalFile, originalTopicClass, processedParents);
{
    my ($self, $inheritedMethods, $topicClass, $parsedFiles, $originalFile, $originalTopicClass, $processedParents) = @_;
	
	my @parentsClasses = split(/:/, $topicClass->Parents());
	my $parentClassIndex;
	
	# For each parent of the given class (of the given file)
	foreach my $parentClass (@parentsClasses)
	{
		my $parentClassFile;
		my $parentParsedFile;
		my $i;
		
		# We search for the parent, on each file
		foreach my $parentFile (keys %$parsedFiles)
		{
			$parentParsedFile = $parsedFiles->{$parentFile};
			my $type;
			$i = 0;
			
			# For each topic on this given file
			while ( $i < scalar @$parentParsedFile)
			{
				$type = $parentParsedFile->[$i]->Type();
				
				# If the topic is a class
				if ($type eq ::TOPIC_CLASS)
				{
					my $title = $parentParsedFile->[$i]->Title();
					
					# If the class is our parent class
					if ($title eq $parentClass)
					{	
						$parentClassFile = $parentFile;
						$parentClassIndex = $i+1;
						
						# At this point, we get one parent class.
						# We check for parent's parents methods
												
						my $parentTopicClass = $parentParsedFile->[$parentClassIndex-1];
						my %parsedFilesTemp = %$parsedFiles;
						$self->SearchForParentsAndGetMethods($inheritedMethods, $parentTopicClass, \%parsedFilesTemp
																, $originalFile, $originalTopicClass, $processedParents);						
						
						last;
					}
				}
				$i++;
			}
			
			# We got out of the while, we check if we're good.
			if ($type eq ::TOPIC_CLASS && $i < scalar @$parentParsedFile)
			{
				my $title = $parentParsedFile->[$i]->Title();
				
				# If the class is our parent class
				if ($title eq $parentClass)
				{
					last;
				}	
			}
		}
		
		# At this point, we checked all files for the parent class.
		
		# We make sure that class hasn't already been added (multiple inheritance)
		
		my $isProcessed;
		
		foreach my $processedParent (@$processedParents)
		{
			if ($processedParent eq $parentClass)
			{
				$isProcessed = 1;
				last;
			}
		}
		
		# If class is found and hasn't already been added
		
		if ($parentClassFile && $parentClassIndex < scalar @$parentParsedFile && !$isProcessed)
		{
			push @$processedParents, $parentClass;
			
			# We create a group for the inherited methods
			my $groupText = "Inherited Functions from ";
			my $parentGroupTopic = NaturalDocs::Parser::ParsedTopic->New(::TOPIC_GROUP, $groupText . $parentClass);
			
			# Variable to check if it's the first time we add a function for this class, and if so, creates a topic group
			# for the class
			my $isFirstTime = 1;
			
			my $type;
			# Stores last topic's access.
			my %lastModifiers = {	'access' => -1,
									'sealed' => -1,
									'static' => -1,
									'abstract' => -1,
									'const' => -1 };
									
			# We loop on parent's topic
			do
			{
				$type = $parentParsedFile->[$parentClassIndex]->Type();
				if ($type eq ::TOPIC_FUNCTION)
				{
					my $topic = $parentParsedFile->[$parentClassIndex];
					
					# Building the link to parent's function					
					my $parentLink = $self->BuildLink($originalFile, $parentClassFile, $topic, $parentClass);
					
					# Create topic for parent's function
					my $inheritedTopic = NaturalDocs::Parser::ParsedTopic->New($topic->Type(), $topic->Title(),
														 $topic->Package(), $topic->Using(),
														 undef,
														 'See ' . $parentLink, 'See ' . $parentLink, undef, undef);
										
					my %modifiers = $topic->Modifiers();
					
					$inheritedTopic->SetModifiers(%modifiers);
					
					# Variable that says if we have to add the function or not. We don't add function if it's abstract
					# and implemented in an original class' superclass
					my $addMethod = 1;
					
					# If method is abstract
					if ($modifiers{'abstract'} eq '1')
					{
						# We search for its implementation. If it's found, we don't add the method.
						# If it's found in the original class, we add a link to the abstract declaration
						my $link = $self->TryToFindImplementationOfAbstractMethod(	$originalFile, $inheritedTopic, 
																					$parsedFiles, $originalFile, $parentClassFile);
																					
						# If we have a link, it means we don't need to add the parent method to the parsed file
						if ($link)
						{	$addMethod = undef;	}
						my $index = 0;
						
						# Check if we find implementation on the original class
						while ($index < scalar @$originalTopicClass)
						{
							if ($originalTopicClass->[$index]->Title() eq $topic->Title())
							{
								my %originalTopicModifiers = $originalTopicClass->[$index]->Modifiers();
								# If topic we found is not abstract, we add the previously built link
								if ($originalTopicModifiers{abstract} ne '1')
								{
									$originalTopicClass->[$index]->SetSummary('Implementation of ' . $link);
									$originalTopicClass->[$index]->SetBody('Implementation of ' . $link. '<br><br>'
																			. $originalTopicClass->[$index]->Body());
								}
								# If topic we found is still abstract, we add parentLink
								else 
								{
									$originalTopicClass->[$index]->SetSummary('Implementation of ' . $parentLink);
									$originalTopicClass->[$index]->SetBody('Implementation of ' . $parentLink. '<br><br>'
																			. $originalTopicClass->[$index]->Body());
								}
								last;
							}
							$index++
						}
					}
					
					# If access is not private, we add the function
					if ($addMethod && $modifiers{'access'} ne '3')
					{
						# If it's the first function we add from this class, we add a new group
						if ($isFirstTime)
						{
							$isFirstTime = undef;
							push @$inheritedMethods, $parentGroupTopic;
						}
						# We try to create a new modifiers group, and if we manage to, we add it
						my $groupTopic = $self->TryToCreateNewModifiersGroup(\%lastModifiers, %modifiers);
						if ($groupTopic)
						{	push @$inheritedMethods, $groupTopic;	}
						
						# We add the inherited topic
						push @$inheritedMethods, $inheritedTopic;
					}
				}
				
				# We don't want inherited methods from "grand"-parents classes since we'll get them recursively
				if ($type eq ::TOPIC_GROUP && $parentParsedFile->[$parentClassIndex]->Title() =~ /^($groupText)/)
				{
					goto EndDo;
				}
				
				$parentClassIndex++;
			}
			while ($parentClassIndex < scalar @$parentParsedFile && $type ne ::TOPIC_CLASS);
			
			EndDo:	# Yeah, that sucks
		}
		
	}
}


#
#   Function: TryToFindImplementationOfAbstractMethod
#
#	For a given abstract method (methodToFind), we try to find its implementation in every parents classes of the
#	original class (originalFile), until we reach the class in which the abstract method was found (methodFile). 
#	If it's found, returns a link to the abstract declaration. If not, returns undef.
#
#   Parameters:
#
#		classFile - The file containing the class in which we a searching for implementation of the method
#		methodToFind - Topic of the function we're looking to find its implementation
#		parsedFiles - A reference to the hash containing all parsedFiles
#		originalFile - The complete path to the file containing the class in which we a searching for 
#						implementation of the method in the first place
#		methodFile - The file in which the method we're looking for is
#

sub TryToFindImplementationOfAbstractMethod #(classFile, methodToFind, parsedFiles, originalFile, methodFile)
{
	my ($self, $classFile, $methodToFind, $parsedFiles, $originalFile, $methodFile) = @_;
	
	my $isFound;
	
	my $parsedFile = $parsedFiles->{$classFile};
	my $methodParsedFile = $parsedFiles->{$methodFile};
	my ($methodClassName, $index) = $self->GetClassName($methodParsedFile);
	
	my @parentsClasses;
	
	# We first check the current class	
	foreach my $parsedTopic (@$parsedFile)
	{
		# Get parents while we're here
		if ($parsedTopic->Type() eq ::TOPIC_CLASS())
		{
			@parentsClasses = split(/:/, $parsedTopic->Parents());
		}
		my %modifiers = $parsedTopic->Modifiers();
		
		# If topic is function, has the right name and isn't abstract
		if ($parsedTopic->Type() eq ::TOPIC_FUNCTION() && 
			$parsedTopic->Title() eq $methodToFind->Title() &&
			$modifiers{'abstract'} eq '0'
			)
		{
			$isFound = 1;
			
			# If the implementation is on our original class
			if ($classFile eq $originalFile)
			{
				my $link = $self->BuildLink($originalFile, $methodFile, $methodToFind, $methodClassName);
				return $link;
			}
		}
		
		# If we're at the parent class, we get out
		if ($parsedTopic->Type() eq ::TOPIC_CLASS() && 
			$parsedTopic->Title() eq $methodClassName
			)
		{
			return undef;
		}
	}
	
	# If we found implementation
	if ($isFound)
	{
		my ($className, $index) = $self->GetClassName($parsedFile);
		my $link = $self->BuildLink($originalFile, $methodFile, $methodToFind, $className);
		return $link;
	}
	else #if (!$isFound)
	{
		# We search for each parents...
		foreach my $parentClass (@parentsClasses)
		{
			# ... on each file ...
			foreach my $parentFile (keys %$parsedFiles)
			{
				my $parentParsedFile = $parsedFiles->{$parentFile};
				my $i = 0;
				
				# ... on each topic
				while ( $i < scalar @$parentParsedFile)
				{
					my $type = $parentParsedFile->[$i]->Type();
					
					# If the topic is a class
					if ($type eq ::TOPIC_CLASS)
					{
						my $title = $parentParsedFile->[$i]->Title();
						
						# If the class is our parent class
						if ($title eq $parentClass)
						{	
							# If we found parent class, we look for implementation on it
							my $link = $self->TryToFindImplementationOfAbstractMethod(	$parentFile, $methodToFind, 
																						$parsedFiles, $originalFile, $methodFile);
							if ($link)
							{	return $link;	}
						}	
					}
					$i++;
				}
			}	
		}
	}
	# If we're here, it means we found nothing on the original class, nor on its parents.
	return undef;	
}

###############################################################################
# Group: Sorting Functions

#
#   Function: CountFunctionsAndJumpLines
#
#	For the given class, if the number of function in a given group is over MAX_FUNCTIONS, 
#	we seperate them by their first letter.
#
#   Parameters:
#
#       parsedFile - A reference to the array containing all topics from the parsed file
#

sub CountFunctionsAndJumpLines #(parsedFile)
{
    my ($self, $parsedFile) = @_;
	
	my $index;
	my $startIndex;
	my $lastIsFunction = 0;
	my %lastModifiers;
	
	while ($index < scalar @$parsedFile)
	{
		my %modifiers = $parsedFile->[$index]->Modifiers();
		
		# If we find a function, and we were not in functions, we start recording
		if ($parsedFile->[$index]->Type() eq ::TOPIC_FUNCTION && $lastIsFunction == 0)
		{
			$startIndex = $index;
			%lastModifiers = $parsedFile->[$index]->Modifiers();
			$lastIsFunction = 1;
		}
		# Code below is useless now that we seperate function with different modifiers with groups
		
		# If we're in functions, topic is function BUT modifiers changed, we try to JumpLines for the past record
		# and we start a new record		
		# elsif (	$parsedFile->[$index]->Type() eq ::TOPIC_FUNCTION && 
				# $self->TryToCreateNewModifiersGroup(\%lastModifiers, %modifiers) && 
				# $lastIsFunction == 1)
		# {
			# if($index - $startIndex > $MAX_FUNCTIONS)
			# {
				# $self->JumpLines($startIndex, $index-1, $parsedFile, \$index);
			# }
			# $startIndex = $index;
		# }
		
		# If we ne longer find function
		elsif($parsedFile->[$index]->Type() ne ::TOPIC_FUNCTION && $lastIsFunction == 1)
		{
			$lastIsFunction = 0;
			if($index - $startIndex > $MAX_FUNCTIONS)
			{
				$self->JumpLines($startIndex, $index-1, $parsedFile, \$index);
			}
		}
		$index++;
	}
	
	# We got out, it's (highly) possible that last topic was a function, so we check
	if ($lastIsFunction == 1 && $index - $startIndex > $MAX_FUNCTIONS)
	{
		$self->JumpLines($startIndex, $index-1, $parsedFile, \$index);
	}

}

#
#   Function: JumpLines
#
#	Between startIndex and endIndex, we add a new group for each new first letter of function name
#
#   Parameters:
#
#		startIndex - The index from which you want to jump lines
#		endIndex - The index where you want to stop jumping lines (inclusive)
#       parsedFile - A reference to the array containing all topics from the parsed file
#		index - A reference to the current index of your parsedFile (it's going to change since we're 
#					adding groups)
#

sub JumpLines #(startIndex, endIndex, parsedFile, index)
{
    my ($self, $startIndex, $endIndex, $parsedFile, $index) = @_;
	
	my $lastLetter;
	
	while($startIndex <= $endIndex)
	{
		@$parsedFile[$startIndex]->Title() =~ /^([a-z])/i;
		if (lc($1) ne $lastLetter)
		{
			$lastLetter = lc($1);
			my $groupTopic = NaturalDocs::Parser::ParsedTopic->New(::TOPIC_GROUP, lc($1));
			splice (@$parsedFile, $startIndex, 0, $groupTopic);
			
			# Since we added a topic, we have to raise startIndex, endIndex and index
			$endIndex++;
			$startIndex++;
			$$index++;
		}
		$startIndex++;
	}	
}
	
#
#	Function: SortByName
#
#	Sorts every proprties / functions by name, inside any group they could be.
#
#   Parameters:
#
#       parsedFile - A reference to the array containing all topics from the parsed file
#

sub SortByName #(parsedFile)
{
    my ($self, $parsedFile) = @_;
	
    my $index = 0;
	my $startIndex;
	my $endIndex;

    while ($index < scalar @$parsedFile)
	{
		my $type = $parsedFile->[$index]->Type();
		
		# If we're in a new group, we sort inside it
		if ( $type eq ::TOPIC_GROUP() )
		{
			$startIndex = ++$index;
			$type = $parsedFile->[$index]->Type();
			
			# Properties and functions can only be followed by groups (in the current version)
			while ($type ne ::TOPIC_GROUP() && $index < (scalar @$parsedFile -1) )
			{
				my $name = $parsedFile->[$index]->Title();
				$type = $parsedFile->[++$index]->Type();
			}
			# Hack in case we're at the end of file
			if ($index > scalar @$parsedFile -2 && $parsedFile->[$index]->Type() ne ::TOPIC_GROUP() )
			{	$endIndex = $index;	}
			else 
			{	$endIndex = $index -1;	};
			
			$self->SortIndexesByName($startIndex, $endIndex, \$index, $parsedFile);
		}
		# if ( $type eq ::TOPIC_CLASS() )
		# {	$index++;	}
		# elsif ( $type eq ::TOPIC_FUNCTION() )
		# {	$index++;	}
		# elsif ( $type eq ::TOPIC_PROPERTY() )
		# {	$index++;	}
		else
		{	$index++;	}
	}
}

#
#	Function: SortIndexesByName 
#
#	From "startIndex" and until "endIndex", sorts all elements of @parsedFile, first by their modifiers, 
#	and then alphabetically. Also creates a group for each new modifiers.
#
#   Parameters:
#
#		startIndex - The index from which you want to sort by name
#		endIndex - The index where you want to stop sorting by name (inclusive)
#		index - A reference to the current index of your parsedFile (it's going to change since we're 
#					adding groups)
#       parsedFile - A reference to the array containing all topics from the parsed file
#

sub SortIndexesByName #(startIndex, endIndex, indexRef, $parsedFile)
{
	my ($self, $startIndex, $endIndex, $index, $parsedFile) = @_;

	my %topics;
	my @sortedTopics;
	my $i = $startIndex;
	
	# We change every topic name (temporary) and store them in a hash, that have the new name as key, and the topic as value
	# in order to sort them using the Sort() function
	while ($i < ($endIndex + 1) )
	{
		my %modifiers = $parsedFile->[$i]->Modifiers();
		my $modifiersOrder;
		
		# This ugly thing is to sort our modifier by this given order :
		# Public > Protected > Private
		#
		# After that, we also want
		# Sealed > Static > Abstract
		
		$modifiersOrder .= $modifiers{'access'};
		$modifiersOrder .= $modifiers{'abstract'};
		$modifiersOrder .= $modifiers{'static'};
		$modifiersOrder .= $modifiers{'sealed'};
		$modifiersOrder .= $modifiers{'const'};
		
		my $topicTitle = $modifiersOrder . lc($parsedFile->[$i]->Title());
		$topics{ $topicTitle } = $parsedFile->[$i++];
	};
	
	# Stores last topic's access.
	my %lastModifiers = {	'access' => -1,
							'sealed' => -1,
							'static' => -1,
							'abstract' => -1,
							'const' => -1 };
	
	# We sort topics 
	foreach my $topicTitle (sort (keys(%topics) ) )
	{
		my %modifiers = $topics{$topicTitle}->Modifiers();
		
		# We try create group if modifiers changed
		my $groupTopic = $self->TryToCreateNewModifiersGroup(\%lastModifiers, %modifiers);
		
		# If that's the case, we raise index since we added a topic
		if ($groupTopic)
		{
			push @sortedTopics, $groupTopic;
			$$index++;
		}
	
		push @sortedTopics, $topics{$topicTitle};
	}
	
	# That splice replace all previous topics by the new array of sorted ones
	splice(@$parsedFile, $startIndex, $endIndex - $startIndex + 1, @sortedTopics);
}

###############################################################################
# Group: Support Functions

#
#   Function: GetClassName
#
#	From the given parsedFile, return the name of the classe it contains.
#	We *cannot* have more than one class per file.
#
#   Parameters:
#
#       parsedFile - A reference to the array containing all topics from the parsed file
#

sub GetClassName #(parsedFile)
{
    my ($self, $parsedFile) = @_;

	my $i = 0;
	
    while ($i < scalar @$parsedFile)
	{
		my $type = $parsedFile->[$i]->Type();
		if ($type eq ::TOPIC_CLASS)
		{
			my $className = $parsedFile->[$i]->Title();
			return ($className, $i);
		}
		$i++;
	}
	return undef;
}

#
#   Function: TryToCreateNewModifiersGroup
#
#	From modifiers and lastModifiers, detect if there has been a change in modifiers, and 
#	if so, creates and returns a group topic for those new modifiers
#
#   Parameters:
#
#		lastModifiers - Modifiers of the previous topic
#		modifiers - Modifiers of the current topic
#

sub TryToCreateNewModifiersGroup #(lastModifiers, modifiers) 
{
		
	my ($self, $lastModifiers, %modifiers) = @_;
	my ($hasChanged, $groupTopic);
		
	if ($modifiers{'access'} ne $lastModifiers->{'access'})
	{
		$hasChanged = 1;
		$lastModifiers->{'access'} = $modifiers{'access'};
	}
	if ($modifiers{'sealed'} ne $lastModifiers->{'sealed'})
	{	
		$hasChanged = 1;
		$lastModifiers->{'sealed'} = $modifiers{'sealed'};
	}
	if ($modifiers{'static'} ne $lastModifiers->{'static'})
	{	
		$hasChanged = 1;
		$lastModifiers->{'static'} = $modifiers{'static'};	
	}
	if ($modifiers{'abstract'} ne $lastModifiers->{'abstract'})
	{	
		$hasChanged = 1;
		$lastModifiers->{'abstract'} = $modifiers{'abstract'};	
	}
	if ($modifiers{'const'} ne $lastModifiers->{'const'})
	{	
		$hasChanged = 1;
		$lastModifiers->{'const'} = $modifiers{'const'};	
	}
	if ($hasChanged)
	{
		# We want to display modifiers in the same order we store them in ParsedTopic
		my $accessName;
		if ($lastModifiers->{'access'} == 1)
		{$accessName = 'public ';}
		elsif($lastModifiers->{'access'} == 2)
		{$accessName = 'protected ';}
		elsif($lastModifiers->{'access'} == 3)
		{$accessName = 'private ';}
		
		# We create a new group
		my $groupName = $accessName
						. ($lastModifiers->{'sealed'} == 1 ? ' sealed' : '')
						. ($lastModifiers->{'static'} == 1 ? ' static' : '')
						. ($lastModifiers->{'abstract'} == 1 ? ' abstract' : '')
						. ($lastModifiers->{'const'} == 1 ? ' const' : '');
		$groupTopic = NaturalDocs::Parser::ParsedTopic->New(::TOPIC_GROUP, $groupName);
	}
	return $groupTopic;
}

#
#   Function: BuildLink
#
#	Build HTML link from originalFile to topic (in classFile)
#
#   Parameters:
#
#		originalFile - The file in which the link will be
#		classFile - The file in which the topic you want to link to is
#       topic - The topic you want to link
#		parentClass - The title of classFile
#

sub BuildLink #(originalFile, classFile, topic, parentClass)
{
	my ($self, $originalFile, $classFile, $topic, $parentClass) = @_;
	
	my $symbolTargetFile = NaturalDocs::Builder::HTMLBase->MakeRelativeURL( 
						   NaturalDocs::Builder::HTMLBase->OutputFileOf($originalFile),
						   NaturalDocs::Builder::HTMLBase->OutputFileOf($classFile), 1 );
															  
															
	my $tooltipID = NaturalDocs::Builder::HTMLBase->BuildToolTip($topic->Symbol(), $classFile, $topic->Type(),
									 $topic->Prototype(), $topic->Summary());
									 
	my $toolTipProperties = NaturalDocs::Builder::HTMLBase->BuildToolTipLinkProperties($tooltipID);

	my $link .=
	'<a href="' . $symbolTargetFile . '#' . NaturalDocs::Builder::HTMLBase->SymbolToHTMLSymbol($topic->Symbol())
	. '" ' . $toolTipProperties . '>' . NaturalDocs::Builder::HTMLBase->StringToHTML( $parentClass
	. '.' . $topic->Title()) . '</a>';
	
	return $link;
}

1;