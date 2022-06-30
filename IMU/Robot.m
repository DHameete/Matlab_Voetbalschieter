classdef Robot < handle
    properties (SetAccess = private)
        vel = [0, 0, 0]
        posLocal = [0, 0, 0]
        posGlobal = [0, 0, 0];
        offset = [0, 0, 0];
    end
    properties (Constant)
        xT = 0.25;
%         triangle = [Robot.xT, -Robot.xT*tand(30);
%             -Robot.xT, -Robot.xT*tand(30);
%             0,Robot.xT*tand(60)-Robot.xT*tand(30)];
        triangle = [-Robot.xT*tand(30), Robot.xT;
            -Robot.xT*tand(30), -Robot.xT;
            Robot.xT*tand(60)-Robot.xT*tand(30), 0];
        
        VMAX = [2, 2, 8];
        AMAX = [1.2, 1.2, 6];
    end
    

    methods
        
        function obj = Robot(pos)
            obj.offset= [0,0,-pi/2];
            obj.posGlobal(1:2) = pos(1:2);
            obj.posLocal(3) = mod(pos(3), 2*pi) - pi;
            obj.posGlobal(3) = mod(pos(3), 2*pi);
        end
        
        function update(obj, vel, dt)
            
%             [1.2,1.2,8]
%             obj.acc = (vel - obj.vel) * dt;
            vel = min(max(vel,-obj.VMAX),obj.VMAX);
            
            acc = [vel(1:2),vel(3)] - 0.8 * obj.vel;
            acc = min(max(acc,-obj.AMAX),obj.AMAX);
            
            obj.vel = obj.vel + acc * dt;
            
            obj.posLocal = obj.posLocal + obj.vel * dt;
            obj.posGlobal(1:2) = obj.posGlobal(1:2) + obj.vel(1:2) * ...
                obj.rotationMatrix(obj.posGlobal(3)-pi/2) * dt;
            
            % TODO: HERE
%             obj.posLocal(3) = obj.posLocal(3) + obj.vel(3) * dt;%mod(obj.posLocal(3) + obj.vel(3) * dt,2*pi);
            if obj.posLocal(3) > pi
                obj.posLocal(3) = -2*pi + obj.posLocal(3);
            elseif obj.posLocal(3) < -pi
                obj.posLocal(3) = 2*pi + obj.posLocal(3);
            end
%             out = map(in, 0, 2*pi, -pi, pi)
%             out = ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
%             -pi + (pi - -pi) * (in - 0) / (2*pi - 0)
%             -pi + 2*pi * in/2*pi
            obj.posGlobal(3) = mod(pi + obj.posLocal(3),2*pi);

        end
        
        function setPositionHandle(obj,pHandle)
            pos = obj.triangle * obj.rotationMatrix(obj.posGlobal(3)) + ...
                obj.posGlobal(1:2);
            set(pHandle,'Xdata',pos(:,1),'Ydata',pos(:,2))
        end
        
    end
   
    methods (Static)         
        function M = rotationMatrix(th)
            M = [cos(th) sin(th);...
                -sin(th) cos(th)];
        end
    end
end