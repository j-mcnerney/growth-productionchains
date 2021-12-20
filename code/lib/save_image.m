function save_image(h, fileName, savemode)
% saveImage(h, fileName, savemode) saves the figure with handle h as the
% .eps file [fileName].eps.
%
% Because of the challenges with saving images, there are several modes in
% which it operates, with different tradefoffs:
%
% * When savemode = 'psc', saveImage is just a wrapper for
%   saveas(h,fileName,'psc'), which saves a postcript file with no bounding
%   box.  The resulting image file is (by default) on a 8.5x11 page, which
%   can be cropped using pdfcrop.
%
% * When savemode = 'epsc', saveImage is just a wrapper for
%   saveas(h,fileName,'epsc'), which saves a postcript file with a bounding
%   box.  The resulting image file is theoretically tightly cropped around
%   the image, possibly eliminating the need for pdfcrop later.
%
% * When savemode = '2014b', saveImage uses a workaround in response to
%   changes in Matlab 2014b, described here
%
%   http://www.mathworks.com/matlabcentral/answers/162283-why-is-the-figure-in-my-eps-file-generated-using-matlab-r2014b-in-the-wrong-position-and-with-extra
%
%   which otherwise causes .eps files to have incorrect bounding boxes.
%   However, this seems to cause bounding box issues that will later cause
%   pdfcrop to fail.
%
% In general, cropping fails with a large scatter plot regardless of saving
% method: When the number of points in a scatter plot gets large (somewhere
% 10^5 - 10^6), Matlab moves to a different mode of plotting things.  At
% the large end, eps cropping will fail to function.  See for example
%
%   https://www.mathworks.com/matlabcentral/answers/170550-saving-figure-with-large-number-of-data-points

switch savemode
   case 'psc'
      saveas(h,fileName,'psc')
      % When the number of points in a scatter plot gets large (somewhere
      % 10^5 - 10^6), Matlab moves to a different mode of plotting things.  At
      % the large end, eps cropping will fail to function.
      
   case 'epsc'      
      saveas(h,fileName,'epsc')
      % When the number of points in a scatter plot gets large (somewhere
      % 10^5 - 10^6), Matlab moves to a different mode of plotting things.  At
      % the large end, eps cropping will fail to function.
      
   case '2014b'
      h.RendererMode      = 'manual';
      h.Renderer          = 'zbuffer'; %Options: opengl, painters, zbuffer
      
      h.PaperPositionMode = 'auto';
      D = h.PaperPosition;
      h.PaperPosition     = [0 0 D(3) D(4)];
      h.PaperSize         = [D(3) D(4)];
      
      saveas(h,fileName,'psc')
      
   case 'painters_pdf'
      set(gcf,'Renderer','painters')
      saveas(h,fileName,'pdf')
      
   otherwise
      error('save_image: Unrecognized option.')
end



% Let's make a mode with set(gcf,'Renderer','painters')... this seems to be
% needed for saving figures with transparency while still maintaining
% vector ability