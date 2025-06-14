% classdef Constants
%     properties (Constant)
%         FRAMELENGTH     = 119;
%         H               = 360;
%         W               = 480;
%         MACROBLOCKSIZE  = 8;
%         GOP_SIZE        = 30;
%     end
%     methods (Static)
%         function rows = MB_ROWS()
%             rows = Constants.H / Constants.MACROBLOCKSIZE;
%         end
%         function cols = MB_COLS()
%             cols = Constants.W / Constants.MACROBLOCKSIZE;
%         end
%     end
% end

classdef Constants < handle
    properties
        FRAMELENGTH_     = 119;
        H_               = 360;
        W                = 480;
        MACROBLOCKSIZE_  = 8;
        GOP_SIZE_        = 30;  % Now mutable
    end
    properties (Access = public)
        MAX_I            = 255;
    end

    methods (Access = private)
        function obj = Constants()
            % Private constructor
        end
    end

    methods (Static)
        function obj = Instance()
            persistent instance
            if isempty(instance) || ~isvalid(instance)
                instance = Constants();
            end
            obj = instance;
        end

        function rows = MB_ROWS()
            obj = Constants.Instance();
            rows = obj.H_ / obj.MACROBLOCKSIZE_;
        end

        function cols = MB_COLS()
            obj = Constants.Instance();
            cols = obj.W / obj.MACROBLOCKSIZE_;
        end

        function cols = FRAMELENGTH()
            obj = Constants.Instance();
            cols = obj.FRAMELENGTH_;
        end

        function cols = GOP_SIZE()
            obj = Constants.Instance();
            cols = obj.GOP_SIZE_;
        end

        function cols = SET_GOP_SIZE(val)
            obj = Constants.Instance();
            obj.GOP_SIZE_ = val;
        end

        function cols = MACROBLOCKSIZE()
            obj = Constants.Instance();
            cols = obj.MACROBLOCKSIZE_;
        end

        function cols = H()
            obj = Constants.Instance();
            cols = obj.H_;
        end
    end
end