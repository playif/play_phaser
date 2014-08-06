part of tweenengine;

/**
 * TweenCallbacks are used to trigger actions at some specific times.
 * They are used in both Tweens and Timelines.
 * The moment when the callback is triggered depends on its registered triggers:
 *
 * * [TweenCallback.BEGIN]: right after the delay (if any)
 * * [TweenCallback.START]: at each iteration beginning
 * * [TweenCallback.END]: at each iteration ending, before the repeat delay
 * * [TweenCallback.COMPLETE]: at last END event
 * * [TweenCallback.BACK_BEGIN]: at the beginning of the first backward iteration
 * * [TweenCallback.BACK_START]: at each backward iteration beginning, after the repeat delay
 * * [TweenCallback.BACK_END]: at each backward iteration ending
 * * [TweenCallback.BACK_COMPLETE]: at last BACK_END event
 * 
 * forward :      BEGIN                                   COMPLETE
 * forward :      START    END      START    END      START    END
 * |--------------[XXXXXXXXXX]------[XXXXXXXXXX]------[XXXXXXXXXX]
 * backward:      bEND  bSTART      bEND  bSTART      bEND  bSTART
 * backward:      bCOMPLETE                                 bBEGIN
 *
 * see [Tween]
 * see [Timeline]
 * author 
 *    Aurelien Ribon | http://www.aurelienribon.com/ (Original java code)
 *    Xavier Guzman (dart port)
 */
class TweenCallback {
    static const int BEGIN = 0x01;
    static const int START = 0x02;
    static const int END = 0x04;
    static const int COMPLETE = 0x08;
    static const int BACK_BEGIN = 0x10;
    static const int BACK_START = 0x20;
    static const int BACK_END = 0x40;
    static const int BACK_COMPLETE = 0x80;
    static const int ANY_FORWARD = 0x0F;
    static const int ANY_BACKWARD = 0xF0;
    static const int ANY = 0xFF;

    ///The handler to execute when an event occur in the [Tween] or [Timeline]
    CallbackHandler onEvent;
}

///a handler which can take actions when any event occurs on a tween
typedef void CallbackHandler(int type, BaseTween source);