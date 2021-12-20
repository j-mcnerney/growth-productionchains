function memorizeObjPositions(hParent, get_or_set, propertyName, propertyValue, matFile)
% memorizeObjPositions(hParent, get_or_set, 'propertyName', propertyValue,
% matFileDirectory) memorizes the current locations of graphics objects
% with a specified property value and restores their locations at a later
% time.
%
% In typical usage, memorizeObjPositions would be used within a script or
% function that generates a figure with a large number of data labels.
% For example, a user might plot a set of data points that correspond to
% countries, with country names labelling individual points.  A user can
% tweak the positions of these labels by hand to produce a more
% visually-appealing plot, and then have the new positions 'memorized' with
%
%   memorizeObjPositions(hParent, 'get', propertyName, propertyValue, matFile)
%
% Once saved, the user can restore the memorized locations with
%
%   memorizeObjPositions(hParent, 'set', propertyName, propertyValue, matFile)
%
% To ensure that memorizeObjPositions identifies the correct graphics
% objects to move, the user gives these objects an identifying string
% property when they are created.  Unless they are being used for other
% purposes, the 'Tag' and 'UserData' properties are generally good options,
% e.g.
%
%   text(0.3,0.2, '1994', 'Tag','year', matFile)
%   text(0.5,0.7, '2001', 'UserData','year', matFile)
%
% Alternatively, if the user just wants to memorize and move all text
% objects, this step is unneeded.  In this case, run memorizeObjPositions
% with the property name set to 'Type' and the property value set to
% 'Text':
%
%   memorizeObjPositions(hParent, 'set', 'Type','Text', matFile)
%
% Note that the positions are stored in a .mat file with name
% 'objPositions_[propertyValue].mat'.  Care must be taken to ensure that
% this file is not accidentally removed or overwritten.
%
%
% Example:
%
% % Create a figure with labels
% figure(1)
% clf
% hHello = text(0.1, 0.1, 'hello', 'Tag','dont_move');
% h1994  = text(0.5, 0.25,'1994', 'Tag', 'move_this');
% h1997  = text(0.75,0.5, '1997', 'Tag', 'move_this');
% title('Saved locations')
% pause
% 
% % Save these positions
% propertyName     = 'tag';
% propertyValue    = 'move_this';
% matFileDirectory = './objpos_move_this.mat';
% memorizeObjPositions(gcf, 'get', propertyName, propertyValue, matFileDirectory)
% 
% % Change text positions
% set(hHello, 'Position',rand(1,3))
% set(h1994,  'Position',rand(1,3))
% set(h1997,  'Position',rand(1,3))
% title('New locations')
% pause
% 
% % Return text to saved positions
% memorizeObjPositions(gcf, 'set', propertyName, propertyValue, matFileDirectory)
% title('Saved locations restored')
% delete objPositions_move_this.mat



% Identify objects with the specified property value
objectArray = findobj(hParent, propertyName,propertyValue);
nObjects    = length(objectArray);
if nObjects == 0
   error('memorizeObjPositions: No graphics objects with specified propertyValue.')
end

% Construct name of mat file containing object positions
switch get_or_set
   
   case 'get'
      % Save positions of objects with the specified property
      objectPositions = zeros(nObjects,3);
      for i = 1:nObjects
         objectPositions(i,:) = get(objectArray(i), 'Position');
      end
      save(matFile, 'objectPositions')
      
   case 'set'
      % Load mat file
      try
         load(matFile)
      catch
         error( ['memorizeObjPositions: Unable to open object positions mat-file: ',matFile] )
      end
      
      % Set positions of objects with the specified property
      for i = 1:nObjects
         set(objectArray(i), 'Position', objectPositions(i,:));
      end
      
   otherwise
      error('memorizeObjPositions: Unrecognized get_or_set')
end
      

