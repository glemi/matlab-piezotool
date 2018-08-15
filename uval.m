classdef uval
    %UVAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Value    % nominal Value
        Plus     % upper Delta
        Minus    % lower Delta
    end
    
    properties(Dependent)
        Delta    % The larger value of abs(Plus) and abs(Minus)
        Upper    % Upper Bound (Value + Delta)
        Lower    % Lower Bound (Value - Delta)
    end
    
    properties(Dependent, SetAccess = private)
        Range    % Interval Range = Plus + Minus = Upper - Lower
        Interval % [Lower Upper]
        PlusMinus % [Plus Minus]
        Relative 
    end
    
    methods
        function this = uval(value, uncert, mode)
            if nargin == 1 && isa(value, 'uval')
                this = value; % copy constructor
                return;
            end
            if nargin < 3
                mode = 'auto';
            end
            if nargin < 2
                uncert = 0; 
            end
            if nargin < 1
                return;
            end
            
            n = numel(value);
            this(n) = uval; % pre-allocate
            for k = 1:n
                this(k) = this(k).create(value(k), uncert, mode);
            end
            this = reshape(this, size(value));
        end
        function this = set.Delta(this, delta)
            this.Plus = abs(delta);
            this.Minus = abs(delta);
        end
        function delta = get.Delta(this)
            delta = max(abs([this.Plus this.Minus]));
        end
        
        function this = set.Upper(this, upper)
            this.Plus = upper - this.Value;
        end
        function upper = get.Upper(this)
            upper = this.Value + this.Plus;
        end
        
        function this = set.Lower(this, lower)
            this.Minus = this.Value - lower;
        end
        function lower = get.Lower(this)
            lower = this.Value - this.Minus;
        end
        
        function interv = get.Interval(this)
            interv = this.Value + [-this.Minus this.Plus];
        end
        function range = get.Range(this)
            range = this.Plus + this.Minus;
        end
        function plusmin = get.PlusMinus(this)
            plusmin = [this.Minus this.Plus];
        end
        function relative = get.Relative(this)
            relative = this.PlusMinus/this.Value;
        end
        
        function d = double(a)
            d = uval.arrayop(@op,a,1);
            function b = op(a,~)
                b = a.Value;
            end
        end
        function c = plus(a, b)
            c = uval.arrayop(@op,a,b);
            function c = op(a,b)
                a = uval(a);
                b = uval(b);
                value = a.Value + b.Value;
                minus = a.Minus + b.Minus;
                plus  = a.Plus  + b.Plus;
                c = uval(value, [plus minus], 'delta');
            end
        end        
        function c = minus(a, b)
            c = a + (-b);
        end
        function b = uminus(a)
            b = uval.arrayop(@op,a,1);
            function b = op(a,~)
                b = uval(-a.Value, [a.Minus a.Plus], 'delta');
            end
        end
        function b = uplus(a)
            b = a;
        end
        function c = times(a, b)
            c = uval.arrayop(@op,a,b);
            function c = op(a,b)
                %TODO: handle case when 0 is within the interval
                if a > 0 && b > 0 
                    intrv = a.Interval.*b.Interval;
                elseif a < 0 && b < 0
                    intrv = flip(a.Interval.*b.Interval);
                elseif a < 0 && b > 0 
                    intrv = a.Interval.*flip(b.Interval);
                elseif a > 0 && b < 0 
                    intrv = flip(a.Interval).*b.Interval;
                elseif isnan(a) || isnan(b)
                    intrv = [NaN NaN];
                end
                value = a.Value*b.Value;
                c = uval(value, intrv, 'interval');
            end
        end   
        function c = mtimes(a, b)
            c = a.*b;
        end
        function c = rdivide(a, b)
            c = uval.arrayop(@op,a,b);
            function c = op(a,b)
                if b > 0
                    b = uval(1/b.Value, 1./flip(b.Interval), 'interval');
                elseif b < 0 
                    b = uval(1/b.Value, 1./b.Interval, 'interval');
                elseif b == 0
                    b = uval(sign(b)*inf, sign(b)*[inf inf]);
                end
                c = a.*b;
            end
        end
        function c = mrdivide(a, b)
            c = a./b;
        end
        function c = power(a, b)
            c = uval.arrayop(@op,a,b);
            function c = op(a,b)
                b = double(b);
                c = uval(a.Value.^b, sort(a.Interval.^b), 'interval');
            end
        end
        function l = lt(a, b)
            avalue = double(a);
            bvalue = double(b);
            l = avalue < bvalue;
        end
        function l = gt(a, b)
            avalue = double(a);
            bvalue = double(b);
            l = avalue > bvalue;
        end
        function l = le(a, b)
            avalue = double(a);
            bvalue = double(b);
            l = avalue <= bvalue;
        end
        function l = ge(a, b)
            avalue = double(a);
            bvalue = double(b);
            l = avalue >= bvalue;
        end
        function l = eq(a, b)
            avalue = double(a);
            bvalue = double(b);
            l = avalue == bvalue;
        end
        function l = ne(a, b)
            avalue = double(a);
            bvalue = double(b);
            l = avalue ~= bvalue;
        end
        function s = sign(a)
            s = sign(double(a));
        end
        
        function l = isnan(a)
            l = isnan(double(a));
        end
        function l = isinf(a)
            l = isinf(double(a));
        end
        function s = sum(a, varargin)
            sz = size(a);
            values = [a.Value]; 
            plus   = [a.Plus]; 
            minus  = [a.Minus];
            
            values = reshape(values, sz);
            plus   = reshape(plus, sz);
            minus  = reshape(minus, sz);
            
            vsum = sum(values, varargin{:});
            psum = sum(plus, varargin{:});
            msum = sum(minus, varargin{:});
            
            s = uval(vsum);
            n = numel(s);
            for k = 1:n
                s(k).Plus = psum(k);
                s(k).Minus = msum(k);
            end
        end
        function [s, i] = sort(a, varargin)
            d = double(a);
            if all(size(d) > 1) 
                error 'Sorting of uval type not supported for matrices.';
            end
            [~, i] = sort(d, varargin{:});
            s = a(i);
        end
        function m = median(a, varargin)
            if isempty(a)
                m = NaN;
            elseif isscalar(a) 
                m = a;
            elseif isvector(a)
                n = numel(a);
                mvalue = median(double(a), varargin{:});
                amean = mean(a, varargin{:});
                % https://physics.stackexchange.com/questions/292871
                % error in median relates to error in mean by r
                r = sqrt(pi*n/(2*n-2)); 
                apm = amean.PlusMinus.*r;
                m = uval(mvalue, apm, 'delta');
            else
                error 'Median of uval type not supported for matrices.';
            end
        end
    end
    
    methods(Access = private)
        function this = create(this, value, uncert, mode)
            this.Value = double(value);
            switch lower(mode)
            case 'auto'
                switch numel(uncert)
                case 1
                    this = this.setDelta(uncert);
                case 2
                    if all(abs(uncert) < abs(value)) 
                        this = this.setDelta(abs(uncert));
                    elseif uncert(1) < value && uncert(2) > value
                        this = this.setInterval(uncert);
                    elseif all(uncert == value)
                        this = this.setDelta(0);
                    elseif all(isnan(uncert))
                        this = this.setDelta(NaN);
                    else
                        error 'Cannot determine uncertainty mode, check values';
                    end
                otherwise
                    error 'Uncertainty Value must have 1 or 2 elements';
                end
            case 'delta'
                this = this.setDelta(uncert);
            case 'interval'
                this = this.setInterval(uncert);
            otherwise 
                error 'Invalid mode: must be auto, delta or interval';
            end
        end
        function this = setDelta(this, delta)
            switch numel(delta)
            case 1 
                this.Delta = delta;
            case 2 
                this.Minus = delta(1);
                this.Plus = delta(2);
            otherwise
                error 'Delta Value must have 1 or 2 elements';
            end
        end
        function this = setInterval(this, interv)
            switch numel(interv)
            case 2 
                this.Lower = interv(1);
                this.Upper = interv(2);
            otherwise
                error 'Interval Value must have exactly 2 elements';
            end
        end
    end
    
    methods(Static, Access = private)
        function c = arrayop(op,a,b)
            a = uval(a);
            b = uval(b);
            if isscalar(a) && ~isscalar(b)
                a = repmat(a, size(b));
            elseif ~isscalar(a) && isscalar(b)
                b = repmat(b, size(a));
            end
            c = arrayfun(op,a,b);
        end
    end
end

