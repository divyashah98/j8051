/*
 * Copyright (c) 2014, Dries007
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 *  Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 *  Neither the name of the project nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

package net.dries007.j8051.compiler.components;

import net.dries007.j8051.util.Constants;

import java.util.Arrays;
import java.util.List;
import java.util.ListIterator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author Dries007
 */
public class Bytes extends Component
{
    public final Type     type;
    public final Object[] objects;

    private Bytes(int startOffset, Matcher matcher, Type type)
    {
        super(matcher.start() + startOffset, matcher.end() + startOffset);
        this.type = type;
        if (type == Type.DS) this.objects = new String[]{matcher.group(1), matcher.group(2)};
        else this.objects = matcher.group(1).split(",\\s*");
    }

    @Override
    public String toString()
    {
        return "BYTES: \t" + type + " \t " + Arrays.toString(objects);
    }

    public static void findBytes(List<Component> components)
    {
        for (Type type : Type.values())
        {
            ListIterator<Component> i = components.listIterator(components.size());
            while (i.hasPrevious())
            {
                Component component = i.previous();
                if (component instanceof UnsolvedComponent)
                {
                    String src = ((UnsolvedComponent) component).contents;

                    Matcher matcher = type.pattern.matcher(src);
                    if (!matcher.find()) continue;
                    i.remove();

                    UnsolvedComponent pre = new UnsolvedComponent(component.getSrcStart(), src.substring(0, matcher.start()));
                    if (pre.shouldAdd()) i.add(pre);

                    Bytes bytes = new Bytes(pre.getSrcEnd(), matcher, type);
                    i.add(bytes);

                    UnsolvedComponent post = new UnsolvedComponent(bytes.getSrcEnd(), src.substring(matcher.end()));
                    if (post.shouldAdd()) i.add(post);
                }
            }
        }
    }

    @Override
    protected Object getContents()
    {
        return Arrays.toString(objects);
    }

    @Override
    protected Object getSubType()
    {
        return type;
    }

    private static enum Type
    {
        DB(Constants.DB), DW(Constants.DW), DS(Constants.DS);

        public final Pattern pattern;

        Type(Pattern pattern)
        {
            this.pattern = pattern;
        }
    }
}
