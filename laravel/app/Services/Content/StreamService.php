<?php

namespace App\Services\Content;

use App\Models\Content\Stream;

class StreamService
{
    public function create(array $data): Stream
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Stream $stream, array $data): Stream
    {
        throw new \LogicException('Not implemented');
    }
    public function goLive(int $id): void
    {
        $stream = Stream::findOrFail($id);
        $stream->goLive();
        $stream->save();
    }

    public function end(int $id): void
    {
        $stream = Stream::findOrFail($id);
        $stream->end();
        $stream->save();
    }

    public function updateViewerPeak(int $id, $count): void
    {
        $stream = Stream::findOrFail($id);
        $stream->updateViewerPeak($count);
        $stream->save();
    }
}
