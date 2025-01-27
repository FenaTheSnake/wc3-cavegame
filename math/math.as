#include "noise.as"

const float e = 2.71828f;

class Vector2 {
    float x, y;

    Vector2() {

    }

    Vector2(const Vector2 &inout other) {
        x = other.x;
        y = other.y;
    }

    Vector2(float x, float y) {
        this.x = x;
        this.y = y;
    }

    bool opEquals(const Vector2 &in other) {
        return this.x == other.x and this.y == other.y;
    }

    Vector2 &opAssign(const Vector2 &in other) {
        this.x = other.x;
        this.y = other.y;
        return this;
    }

    Vector2 &opAddAssign(const Vector2 &in other) {
        this.x += other.x;
        this.y += other.y;
        return this;
    }

    Vector2 &opSubAssign(const Vector2 &in other) {
        this.x -= other.x;
        this.y -= other.y;
        return this;
    }

    Vector2 &opMulAssign(const float &in factor) {
        this.x *= factor;
        this.y *= factor;
        return this;
    }

    Vector2 opAdd(const Vector2 &in other) {
        return Vector2(this.x + other.x, this.y + other.y);
    }

    Vector2 opSub(const Vector2 &in other) {
        return Vector2(this.x - other.x, this.y - other.y);
    }

    Vector2 opMul(const float &in factor) {
        return Vector2(this.x * factor, this.y * factor);
    }

    string opImplConv() const { return R2S(this.x) + " " + R2S(this.y); }

    float Length() {
        return SquareRoot(x*x + y*y);
    }
    float SqrLength() {
        return x*x + y*y;
    }

    Vector2 Normalized() {
        Vector2 result = this;

        float length = Length();
        if (length != 0.0f)
        {
            float ilength = 1.0f/length;

            result.x *= ilength;
            result.y *= ilength;
        }

        return result;
    }
}

class Vector3 {
    float x, y, z;

    Vector3() {

    }

    Vector3(const Vector3 &inout other) {
        x = other.x;
        y = other.y;
        z = other.z;
    }

    Vector3(float x, float y, float z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    bool opEquals(Vector3 other) {
        return this.x == other.x and this.y == other.y and this.z == other.z;
    }

    Vector3 &opAssign(const Vector3 &in other) {
        this.x = other.x;
        this.y = other.y;
        this.z = other.z;
        return this;
    }

    Vector3 &opAddAssign(const Vector3 &in other) {
        this.x += other.x;
        this.y += other.y;
        this.z += other.z;
        return this;
    }

    Vector3 &opSubAssign(const Vector3 &in other) {
        this.x -= other.x;
        this.y -= other.y;
        this.z -= other.z;
        return this;
    }

    Vector3 &opMulAssign(const float &in factor) {
        this.x *= factor;
        this.y *= factor;
        this.z *= factor;
        return this;
    }

    Vector3 opAdd(const Vector3 &in other) {
        return Vector3(this.x + other.x, this.y + other.y, this.z + other.z);
    }
    Vector3 opAdd(const Vector3I &in other) {
        return Vector3(this.x + other.x, this.y + other.y, this.z + other.z);
    }

    Vector3 opSub(const Vector3 &in other) {
        return Vector3(this.x - other.x, this.y - other.y, this.z - other.z);
    }

    Vector3 opMul(const float &in factor) {
        return Vector3(this.x * factor, this.y * factor, this.z * factor);
    }

    string opImplConv() const { return R2S(this.x) + " " + R2S(this.y) + " " + R2S(this.z); }

    float Length() {
        return SquareRoot(x*x + y*y + z*z);
    }
    float SqrLength() {
        return x*x + y*y + z*z;
    }

    Vector3 Normalized() {
        Vector3 result = this;

        float length = Length();
        if (length != 0.0f)
        {
            float ilength = 1.0f/length;

            result.x *= ilength;
            result.y *= ilength;
            result.z *= ilength;
        }

        return result;
    }
}

class Vector3I {
    int x, y, z;

    Vector3I() {

    }

    Vector3I(const Vector3I &inout other) {
        x = other.x;
        y = other.y;
        z = other.z;
    }

    Vector3I(int x, int y, int z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }
    Vector3I(float x, float y, float z) {
        this.x = int(x);
        this.y = int(y);
        this.z = int(z);
    }

    bool opEquals(Vector3I other) {
        return this.x == other.x and this.y == other.y and this.z == other.z;
    }

    Vector3I &opAssign(const Vector3I &in other) {
        this.x = other.x;
        this.y = other.y;
        this.z = other.z;
        return this;
    }

    Vector3I &opAddAssign(const Vector3I &in other) {
        this.x += other.x;
        this.y += other.y;
        this.z += other.z;
        return this;
    }

    Vector3I &opSubAssign(const Vector3I &in other) {
        this.x -= other.x;
        this.y -= other.y;
        this.z -= other.z;
        return this;
    }

    Vector3I &opMulAssign(const float &in factor) {
        this.x *= factor;
        this.y *= factor;
        this.z *= factor;
        return this;
    }

    Vector3I opAdd(const Vector3I &in other) {
        return Vector3I(this.x + other.x, this.y + other.y, this.z + other.z);
    }
    Vector3I opAdd(const Vector3 &in other) {
        return Vector3I(this.x + other.x, this.y + other.y, this.z + other.z);
    }

    Vector3I opSub(const Vector3I &in other) {
        return Vector3I(this.x - other.x, this.y - other.y, this.z - other.z);
    }

    Vector3I opMul(const float &in factor) {
        return Vector3I(this.x * factor, this.y * factor, this.z * factor);
    }

    string opImplConv() const { return this.x + " " + this.y + " " + this.z; }

    float Length() {
        return SquareRoot(x*x + y*y + z*z);
    }
    float SqrLength() {
        return x*x + y*y + z*z;
    }

    Vector3 Normalized() {
        Vector3 result = Vector3(x,y,z);

        float length = Length();
        if (length != 0.0f)
        {
            float ilength = 1.0f/length;

            result.x *= ilength;
            result.y *= ilength;
            result.z *= ilength;
        }

        return result;
    }
}

class Quaternion {
    float x, y, z, w;

    Quaternion() {

    }

    Quaternion(const Quaternion &inout other) {
        x = other.x;
        y = other.y;
        z = other.z;
        w = other.w;
    }

    Quaternion(float x, float y, float z, float w) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }

    bool opEquals(Quaternion other) {
        return this.x == other.x and this.y == other.y and this.z == other.z and this.w == other.w;
    }

    Quaternion &opAssign(const Quaternion &inout other) {
        this.x = other.x;
        this.y = other.y;
        this.z = other.z;
        this.w = other.w;
        return this;
    }

    Quaternion &opAddAssign(const Quaternion &inout other) {
        this.x += other.x;
        this.y += other.y;
        this.z += other.z;
        this.w += other.w;
        return this;
    }

    string opImplConv() const { return R2S(this.x) + " " + R2S(this.y) + " " + R2S(this.z) + " " + R2S(this.w); }
}

float Exp(float x) {
    return Pow(e, x);
}

// alternative to lerp with correct deltaTime handling
// https://www.youtube.com/watch?v=LSNQuFEDOyQ&t=2988s
float expDecay(float a, float b, float decay, float dt)
{
    return b + (a - b) * Exp(-decay * dt);
}

float Vector2Distance(Vector2 v1, const Vector2 &in v2) {
    return (v1-v2).SqrLength();
}

float Vector3Distance(Vector3 v1, const Vector3 &in v2) {
    return (v1-v2).SqrLength();
}

Vector3 Vector3CrossProduct(const Vector3 &in v1, const Vector3 &in v2) {
    return Vector3(v1.y*v2.z - v1.z*v2.y, v1.z*v2.x - v1.x*v2.z, v1.x*v2.y - v1.y*v2.x);
}

float Vector3DotProduct(Vector3 v1, Vector3 v2)
{
    return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
}

Vector3 GetCameraForward() {
    Vector3 eye = Vector3(GetCameraEyePositionX(), GetCameraEyePositionY(), GetCameraEyePositionZ());
    Vector3 target = Vector3(GetCameraTargetPositionX(), GetCameraTargetPositionY(), GetCameraTargetPositionZ());
    Vector3 ret = (target-eye).Normalized();
    //__debug("cam forward " + ret);
    return ret;
}
Vector3 GetCameraUp() {
    return Vector3(0.0f, 0.0f, 1.0f);
}
Vector3 GetCameraRight() {
    Vector3 forward = GetCameraForward();
    Vector3 up = GetCameraUp();

    return Vector3CrossProduct(forward, up);
}

bool IsZero(float val) {
    return val < EPSILON && val > -EPSILON;
}

string UInt2StringLengthOf3(uint val) {
    if(val < 10) return "00" + val;
    if(val < 100) return "0" + val;
    return "" + val;
}

uint HIWORD(uint val) {
    return (val >> 16) & 0x0000FFFF;
}
uint LOWORD(uint val) {
    return val & 0x0000FFFF;
}

uint UINTID2ChunkFileID(uint val) {
    return (val >> 12) & 0x000FFFFF;
}
uint UINTID2ChunkID(uint val) {
    return val & 0x00000FFF;
}